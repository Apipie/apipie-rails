require 'apipie/static_dispatcher'
require 'apipie/routes_formatter'
require 'yaml'
require 'digest/sha1'
require 'json'

module Apipie

  class Application
    # we need engine just for serving static assets
    class Engine < Rails::Engine
      initializer "static assets", :before => :build_middleware_stack do |app|
        app.middleware.use ::Apipie::StaticDispatcher, "#{root}/app/public"
      end
    end

    attr_reader :resource_descriptions

    def initialize
      super
      init_env
    end

    def available_versions
      @resource_descriptions.keys.sort
    end

    def set_resource_id(controller, resource_id)
      @controller_to_resource_id[controller] = resource_id
    end

    def rails_routes(route_set = nil)
      if route_set.nil? && @rails_routes
        return @rails_routes
      end
      route_set ||= Rails.application.routes
      # ensure routes are loaded
      Rails.application.reload_routes! unless Rails.application.routes.routes.any?

      flatten_routes = []

      route_set.routes.each do |route|
        if route.app.respond_to?(:routes) && route.app.routes.is_a?(ActionDispatch::Routing::RouteSet)
          # recursively go though the moutned engines
          flatten_routes.concat(rails_routes(route.app.routes))
        else
          flatten_routes << route
        end
      end

      @rails_routes = flatten_routes
    end

    # the app might be nested when using contraints, namespaces etc.
    # this method does in depth search for the route controller
    def route_app_controller(app, route, visited_apps = [])
      if route.defaults[:controller]
        controller_name = "#{route.defaults[:controller]}_controller".camelize
        controller_name.safe_constantize
      end
    end

    def routes_for_action(controller, method, args)
      routes = rails_routes.select do |route|
        controller == route_app_controller(route.app, route) &&
            method.to_s == route.defaults[:action]
      end

      Apipie.configuration.routes_formatter.format_routes(routes, args)
    end

    # create new method api description
    def define_method_description(controller, method_name, dsl_data)
      return if ignored?(controller, method_name)
      ret_method_description = nil

      versions = dsl_data[:api_versions] || []
      versions = controller_versions(controller) if versions.empty?

      versions.each do |version|
        resource_name_with_version = "#{version}##{get_resource_name(controller)}"
        resource_description = get_resource_description(resource_name_with_version)

        if resource_description.nil?
          resource_description = define_resource_description(controller, version)
        end

        method_description = Apipie::MethodDescription.new(method_name, resource_description, dsl_data)

        # we create separate method description for each version in
        # case the method belongs to more versions. We return just one
        # becuase the version doesn't matter for the purpose it's used
        # (to wrap the original version with validators)
        ret_method_description ||= method_description
        resource_description.add_method_description(method_description)
      end

      return ret_method_description
    end

    # create new resource api description
    def define_resource_description(controller, version, dsl_data = nil)
      return if ignored?(controller)

      resource_name = get_resource_name(controller)
      resource_description = @resource_descriptions[version][resource_name]
      if resource_description
        # we already defined the description somewhere (probably in
        # some method. Updating just meta data from dsl
        resource_description.update_from_dsl_data(dsl_data) if dsl_data
      else
        resource_description = Apipie::ResourceDescription.new(controller, resource_name, dsl_data, version)

        Apipie.debug("@resource_descriptions[#{version}][#{resource_name}] = #{resource_description}")
        @resource_descriptions[version][resource_name] ||= resource_description
      end

      return resource_description
    end

    # recursively searches what versions has the controller specified in
    # resource_description? It's used to derivate the default value of
    # versions for methods.
    def controller_versions(controller)
      ret = @controller_versions[controller.to_s]
      return ret unless ret.empty?
      if controller == ActionController::Base || controller.nil?
        return [Apipie.configuration.default_version]
      else
        return controller_versions(controller.to_s.constantize.superclass)
      end
    end

    def set_controller_versions(controller, versions)
      @controller_versions[controller.to_s] = versions
    end

    def add_param_group(controller, name, &block)
      key = "#{controller.name}##{name}"
      @param_groups[key] = block
    end

    def get_param_group(controller, name)
      key = "#{controller.name}##{name}"
      if @param_groups.has_key?(key)
        return @param_groups[key]
      else
        raise "param group #{key} not defined"
      end
    end

    # get api for given method
    #
    # There are two ways how this method can be used:
    # 1) Specify both parameters
    #   resource_name:
    #       controller class - UsersController
    #       string with resource name (plural) and version - "v1#users"
    #   method_name: name of the method (string or symbol)
    #
    # 2) Specify only first parameter:
    #   resource_name: string containing both resource and method name joined
    #   with '#' symbol.
    #   - "users#create" get default version
    #   - "v2#users#create" get specific version
    def get_method_description(resource_name, method_name = nil)
      if resource_name.is_a?(String)
        crumbs = resource_name.split('#')
        if method_name.nil?
          method_name = crumbs.pop
        end
        resource_name = crumbs.join("#")
        resource_description = get_resource_description(resource_name)
      elsif resource_name.respond_to? :apipie_resource_descriptions
        resource_description = get_resource_description(resource_name)
      else
        raise ArgumentError.new("Resource #{resource_name} does not exists.")
      end
      unless resource_description.nil?
        resource_description.method_description(method_name.to_sym)
      end
    end
    alias :[] :get_method_description

    # options:
    # => "users"
    # => "v2#users"
    # =>  V2::UsersController
    def get_resource_description(resource, version = nil)
      if resource.is_a?(String)
        crumbs = resource.split('#')
        if crumbs.size == 2
          version = crumbs.first
        end
        version ||= Apipie.configuration.default_version
        if @resource_descriptions.has_key?(version)
          return @resource_descriptions[version][crumbs.last]
        end
      else
        resource_name = get_resource_name(resource)
        if version
          resource_name = "#{version}##{resource_name}"
        end

        if resource_name.nil?
          return nil
        end
        resource_description = get_resource_description(resource_name)
        if resource_description && resource_description.controller.to_s == resource.to_s
          return resource_description
        end
      end
    end

    # get all versions of resource description
    def get_resource_descriptions(resource)
      available_versions.map do |version|
        get_resource_description(resource, version)
      end.compact
    end

    # get all versions of method description
    def get_method_descriptions(resource, method)
      get_resource_descriptions(resource).map do |resource_description|
        resource_description.method_description(method.to_sym)
      end.compact
    end

    def remove_method_description(resource, versions, method_name)
      versions.each do |version|
        resource = get_resource_name(resource)
        if resource_description = get_resource_description("#{version}##{resource}")
          resource_description.remove_method_description(method_name)
        end
      end
    end

    # initialize variables for gathering dsl data
    def init_env
      @resource_descriptions ||= HashWithIndifferentAccess.new { |h, version| h[version] = {} }
      @controller_to_resource_id ||= {}
      @param_groups ||= {}
      @swagger_generator = Apipie::SwaggerGenerator.new(self)

      # what versions does the controller belong in (specified by resource_description)?
      @controller_versions ||= Hash.new { |h, controller| h[controller.to_s] = [] }
    end

    def recorded_examples
      return @recorded_examples if @recorded_examples
      @recorded_examples = Apipie::Extractor::Writer.load_recorded_examples
    end

    def reload_examples
      @recorded_examples = nil
    end

    def json_schema_for_method_response(version, controller_name, method_name, return_code, allow_nulls)
      method = @resource_descriptions[version][controller_name].method_description(method_name)
      raise NoDocumentedMethod.new(controller_name, method_name) if method.nil?
      @swagger_generator.json_schema_for_method_response(method, return_code, allow_nulls)
    end

    def json_schema_for_self_describing_class(cls, allow_nulls)
      @swagger_generator.json_schema_for_self_describing_class(cls, allow_nulls)
    end

    def to_swagger_json(version, resource_name, method_name, lang, clear_warnings=false)
      return unless valid_search_args?(version, resource_name, method_name)

      # if resource_name is blank, take just resources which have some methods because
      # we dont want to show eg ApplicationController as resource
      # otherwise, take only the specified resource
      _resources = resource_descriptions[version].inject({}) do |result, (k,v)|
         if resource_name.blank?
           result[k] = v unless v._methods.blank?
         else
           result[k] = v if k == resource_name
         end
         result
       end

      @swagger_generator.generate_from_resources(version,_resources, method_name, lang, clear_warnings)
    end

    def to_json(version, resource_name, method_name, lang)

      return unless valid_search_args?(version, resource_name, method_name)

      _resources = if resource_name.blank?
        # take just resources which have some methods because
        # we dont want to show eg ApplicationController as resource
        resource_descriptions[version].inject({}) do |result, (k,v)|
          result[k] = v.to_json(nil, lang) unless v._methods.blank?
          result
        end
      else
        [@resource_descriptions[version][resource_name].to_json(method_name, lang)]
      end

      url_args = Apipie.configuration.version_in_url ? version : ''

      {
        :docs => {
          :name => Apipie.configuration.app_name,
          :info => Apipie.app_info(version, lang),
          :copyright => Apipie.configuration.copyright,
          :doc_url => Apipie.full_url(url_args),
          :api_url => Apipie.api_base_url(version),
          :resources => _resources
        }
      }
    end

    def api_controllers_paths
      Dir.glob(Apipie.configuration.api_controllers_matcher)
    end

    def reload_documentation
      # don't load translated strings, we'll translate them later
      old_locale = locale
      locale = Apipie.configuration.default_locale

      rails_mark_classes_for_reload

      api_controllers_paths.each do |f|
        load_controller_from_file f
      end
      @checksum = nil if Apipie.configuration.update_checksum

      locale = old_locale
    end

    def load_documentation
      if !@documentation_loaded || Apipie.configuration.reload_controllers?
        Apipie.reload_documentation
        @documentation_loaded = true
      end
    end

    def compute_checksum
      if Apipie.configuration.use_cache?
        file_base = File.join(Apipie.configuration.cache_dir, Apipie.configuration.doc_base_url)
        all_docs = {}
        Dir.glob(file_base + '/*.json').sort.each do |f|
          all_docs[File.basename(f, '.json')] = JSON.parse(File.read(f))
        end
      else
        load_documentation if available_versions == []
        all_docs = Apipie.available_versions.inject({}) do |all, version|
          all.update(version => Apipie.to_json(version))
        end
      end
      Digest::SHA1.hexdigest(JSON.dump(all_docs))
    end

    def checksum
      @checksum ||= compute_checksum
    end

    # Is there a reason to interpret the DSL for this run?
    # with specific setting for some environment there is no reason the dsl
    # should be interpreted (e.g. no validations and doc from cache)
    def active_dsl?
      Apipie.configuration.validate? || ! Apipie.configuration.use_cache? || Apipie.configuration.force_dsl?
    end

    def get_resource_name(klass)
      if klass.class == String
        klass
      elsif @controller_to_resource_id.has_key?(klass)
        @controller_to_resource_id[klass]
      elsif Apipie.configuration.namespaced_resources? && klass.respond_to?(:controller_path)
        return nil if klass == ActionController::Base
        path = klass.controller_path
        path.gsub(version_prefix(klass), "").gsub("/", "-")
      elsif klass.respond_to?(:controller_name)
        return nil if klass == ActionController::Base
        klass.controller_name
      else
        raise "Apipie: Can not resolve resource #{klass} name."
      end
    end

    def locale
      Apipie.configuration.locale.call(nil) if Apipie.configuration.locale
    end

    def locale=(locale)
      Apipie.configuration.locale.call(locale) if Apipie.configuration.locale
    end

    def translate(str, locale)
      if Apipie.configuration.translate
        Apipie.configuration.translate.call(str, locale)
      else
        str
      end
    end

    private

    # Make sure that the version/resource_name/method_name are valid combination
    # resource_name and method_name can be nil
    def valid_search_args?(version, resource_name, method_name)
      return false unless self.resource_descriptions.has_key?(version)
      if resource_name
        return false unless self.resource_descriptions[version].has_key?(resource_name)
        if method_name
          resource_description = self.resource_descriptions[version][resource_name]
          return false unless resource_description.valid_method_name?(method_name)
        end
      end
      return true
    end

    def version_prefix(klass)
      version = controller_versions(klass.to_s).first
      base_url = get_base_url(version)
      return "/" if base_url.blank?
      base_url[1..-1] + "/"
    end

    def get_base_url(version)
      Apipie.configuration.api_base_url[version]
    end

    def get_resource_version(resource_description)
      if resource_description.respond_to? :_version
        resource_description._version
      else
        Apipie.configuration.default_version
      end
    end

    def load_controller_from_file(controller_file)
      require_dependency controller_file
    end

    def ignored?(controller, method = nil)
      ignored = Apipie.configuration.ignored
      return true if ignored.include?(controller.name)
      return true if ignored.include?("#{controller.name}##{method}")
    end

    # Since Rails 3.2, the classes are reloaded only on file change.
    # We need to reload all the controller classes to rebuild the
    # docs, therefore we just force to reload all the code. This
    # happens only when reload_controllers is set to true and only
    # when showing the documentation.
    #
    # If cache_classes is set to false, it does nothing,
    # as this would break loading of the controllers.
    def rails_mark_classes_for_reload
      unless Rails.application.config.cache_classes
        Rails::VERSION::MAJOR == 4 ? ActionDispatch::Reloader.cleanup! : Rails.application.reloader.reload!
        init_env
        reload_examples
        Rails::VERSION::MAJOR == 4 ? ActionDispatch::Reloader.prepare! : Rails.application.reloader.prepare!
      end
    end

  end
end
