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

    def rails_routes(route_set = nil, base_url = "")
      return @_rails_routes if route_set.nil? && @_rails_routes

      route_set ||= Rails.application.routes
      # ensure routes are loaded
      Rails.application.reload_routes! unless Rails.application.routes.routes.any?

      flattened_routes = []

      route_set.routes.each do |route|
        # route is_a ActionDispatch::Journey::Route
        # route.app is_a ActionDispatch::Routing::Mapper::Constraints
        # route.app.app is_a TestEngine::Engine
        route_app = route.app.app
        if route_app.respond_to?(:routes) && route_app.routes.is_a?(ActionDispatch::Routing::RouteSet)
          # recursively go though the mounted engines
          flattened_routes.concat(rails_routes(route_app.routes, File.join(base_url, route.path.spec.to_s)))
        else
          route.base_url = base_url
          flattened_routes << route
        end
      end

      @_rails_routes = flattened_routes
    end

    def rails_routes_by_controller_and_action
      @_rails_routes_by_controller_and_action = rails_routes.group_by do |route|
        requirements = route.requirements
        [requirements[:controller], requirements[:action]]
      end
    end

    def clear_cached_routes!
      @_rails_routes = nil
      @_rails_routes_by_controller_and_action = nil
    end

    def routes_for_action(controller, method, args)
      routes = rails_routes_by_controller_and_action[[controller.name.underscore.chomp('_controller'), method.to_s]] || []

      Apipie.configuration.routes_formatter.format_routes(routes, args)
    end

    # create new method api description
    def define_method_description(controller, method_name, dsl_data)
      return if ignored?(controller, method_name)
      ret_method_description = nil

      versions = dsl_data[:api_versions] || []
      versions = controller_versions(controller) if versions.empty?

      versions.each do |version|
        resource_id_with_version = "#{version}##{get_resource_id(controller)}"
        resource_description = get_resource_description(resource_id_with_version)

        if resource_description.nil?
          resource_description = define_resource_description(controller, version)
        end

        method_description = Apipie::MethodDescription.new(method_name, resource_description, dsl_data)

        # we create separate method description for each version in
        # case the method belongs to more versions. We return just one
        # because the version doesn't matter for the purpose it's used
        # (to wrap the original version with validators)
        ret_method_description ||= method_description
        resource_description.add_method_description(method_description)
      end

      ret_method_description
    end

    # create new resource api description
    def define_resource_description(controller, version, dsl_data = nil)
      return if ignored?(controller)

      resource_id = get_resource_id(controller)
      resource_description = @resource_descriptions[version][resource_id]
      if resource_description
        # we already defined the description somewhere (probably in
        # some method. Updating just meta data from dsl
        resource_description.update_from_dsl_data(dsl_data) if dsl_data
      else
        resource_description = Apipie::ResourceDescription.new(controller, resource_id, dsl_data, version)

        Apipie.debug("@resource_descriptions[#{version}][#{resource_id}] = #{resource_description}")
        @resource_descriptions[version][resource_id] ||= resource_description
      end

      return resource_description
    end

    # recursively searches what versions has the controller specified in
    # resource_description? It's used to derivate the default value of
    # versions for methods.
    def controller_versions(controller)
      value_from_parents(controller, default: [Apipie.configuration.default_version]) do |c|
        ret = @controller_versions[c.to_s]
        ret unless ret.empty?
      end
    end

    # Recursively walks up the controller hierarchy looking for a value
    # from the block.
    # Stops at ActionController::Base.
    # @param [Class] controller controller to start from
    # @param [Array] args arguments passed to the block
    # @param [Object] default default value to return if no value is found
    # @param [Proc] block block to call with controller and args
    def value_from_parents(controller, *args, default: nil, &block)
      return default if controller == ActionController::Base || controller == AbstractController::Base || controller.nil?

      thing = yield(controller, *args)
      thing || value_from_parents(controller.superclass, *args, default: default, &block)
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
      if @param_groups.key?(key)
        return @param_groups[key]
      else
        raise "param group #{key} not defined"
      end
    end

    # get api for given method
    #
    # There are two ways how this method can be used:
    # 1) Specify both parameters
    #   resource_id:
    #       controller class - UsersController
    #       string with resource name (plural) and version - "v1#users"
    #   method_name: name of the method (string or symbol)
    #
    # 2) Specify only first parameter:
    #   resource_id: string containing both resource and method name joined
    #   with '#' symbol.
    #   - "users#create" get default version
    #   - "v2#users#create" get specific version
    def get_method_description(resource_id, method_name = nil)
      if resource_id.is_a?(String)
        crumbs = resource_id.split('#')
        if method_name.nil?
          method_name = crumbs.pop
        end
        resource_id = crumbs.join("#")
        resource_description = get_resource_description(resource_id)
      elsif resource_id.respond_to? :apipie_resource_descriptions
        resource_description = get_resource_description(resource_id)
      else
        raise ArgumentError.new("Resource #{resource_id} does not exists.")
      end
      resource_description&.method_description(method_name.to_sym)
    end
    alias [] get_method_description

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
        if @resource_descriptions.key?(version)
          return @resource_descriptions[version][crumbs.last]
        end
      else
        resource_id = get_resource_id(resource)
        if version
          resource_id = "#{version}##{resource_id}"
        end

        if resource_id.nil?
          return nil
        end
        resource_description = get_resource_description(resource_id)
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
        resource = get_resource_id(resource)
        if resource_description = get_resource_description("#{version}##{resource}")
          resource_description.remove_method_description(method_name)
        end
      end
    end

    # initialize variables for gathering dsl data
    def init_env
      @resource_descriptions = ActiveSupport::HashWithIndifferentAccess.new { |h, version| h[version] = {} }
      @controller_to_resource_id = {}
      @param_groups = {}

      # what versions does the controller belong in (specified by resource_description)?
      @controller_versions = Hash.new { |h, controller| h[controller.to_s] = [] }
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

      Apipie::SwaggerGenerator
        .json_schema_for_method_response(method, return_code, allow_nulls)
    end

    delegate :json_schema_for_self_describing_class, to: :'Apipie::SwaggerGenerator'

    def to_swagger_json(version, resource_id, method_name, language, clear_warnings = false)
      return unless valid_search_args?(version, resource_id, method_name)

      resources =
        Apipie::Generator::Swagger::ResourceDescriptionsCollection
          .new(resource_descriptions)
          .filter(
            resource_id: resource_id,
            method_name: method_name,
            version: version
          )

      Apipie::SwaggerGenerator.generate_from_resources(
        resources,
        version: version,
        language: language,
        clear_warnings: clear_warnings
      )
    end

    def to_json(version, resource_id, method_name, lang)

      return unless valid_search_args?(version, resource_id, method_name)

      _resources = if resource_id.blank?
        # take just resources which have some methods because
        # we dont want to show eg ApplicationController as resource
        resource_descriptions[version].inject({}) do |result, (k,v)|
          result[k] = v.to_json(nil, lang) unless v._methods.blank?
          result
        end
      else
        [@resource_descriptions[version][resource_id].to_json(method_name, lang)]
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

    # @deprecated Use {#get_resource_id} instead
    def get_resource_name(klass)
      ActiveSupport::Deprecation.new('2.0', 'apipie-rails').warn(
        <<~HEREDOC
          Apipie::Application.get_resource_name is deprecated.
          Use `Apipie::Application.get_resource_id instead.
        HEREDOC
      )

      get_resource_id(klass)
    end

    def set_resource_id(controller, resource_id)
      @controller_to_resource_id[controller] = resource_id
    end

    def get_resource_id(klass)
      if klass.class == String
        klass
      elsif @controller_to_resource_id.key?(klass)
        @controller_to_resource_id[klass]
      elsif Apipie.configuration.namespaced_resources? && klass.respond_to?(:controller_path)
        return nil if klass == ActionController::Base

        version_prefix = version_prefix(klass)
        path = klass.controller_path

        unless version_prefix == '/'
          path =
            path.gsub(version_prefix, '')
        end

        path.gsub('/', '-')
      elsif klass.respond_to?(:controller_name)
        return nil if klass == ActionController::Base
        klass.controller_name
      else
        raise "Apipie: Can not resolve resource #{klass} name."
      end
    end

    def locale
      Apipie.configuration.locale&.call(nil)
    end

    def locale=(locale)
      Apipie.configuration.locale&.call(locale)
    end

    def translate(str, locale)
      if Apipie.configuration.translate
        Apipie.configuration.translate.call(str, locale)
      else
        str
      end
    end

    private

    # Make sure that the version/resource_id/method_name are valid combination
    # resource_id and method_name can be nil
    def valid_search_args?(version, resource_id, method_name)
      return false unless self.resource_descriptions.key?(version)
      if resource_id
        return false unless self.resource_descriptions[version].key?(resource_id)
        if method_name
          resource_description = self.resource_descriptions[version][resource_id]
          return false unless resource_description.valid_method_name?(method_name)
        end
      end
      return true
    end

    def version_prefix(klass)
      version = controller_versions(klass).first
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
        clear_cached_routes!
        Rails.application.reloader.reload!
        init_env
        reload_examples
        Rails.application.reloader.prepare!
      end
    end

  end
end
