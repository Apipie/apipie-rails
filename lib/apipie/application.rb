require 'apipie/static_dispatcher'
require 'yaml'

module Apipie

  class Application

    # we need engine just for serving static assets
    class Engine < Rails::Engine
      initializer "static assets" do |app|
        app.middleware.use ::Apipie::StaticDispatcher, "#{root}/app/public", Apipie.configuration.doc_base_url
      end
    end

    attr_accessor :last_api_args, :last_errors, :last_params, :last_description, :last_examples, :last_see, :last_formats
    attr_reader :resource_descriptions

    def initialize
      super
      @resource_descriptions = HashWithIndifferentAccess.new
      clear_last
    end

    def available_versions
      @resource_descriptions.keys.sort
    end

    # create new method api description
    def define_method_description(controller, method_name)
      if ignored?(controller, method_name)
        clear_last
        return
      end

      resource_description = get_resource_description(controller)
      if resource_description.nil?
        resource_description = define_resource_description(controller)
      end
      method_description = Apipie::MethodDescription.new(method_name, resource_description, self)
      resource_description.add_method_description(method_description)
    end

    # create new resource api description
    def define_resource_description(controller, &block)
      if ignored?(controller)
        clear_last
        return
      end

      resource_name = get_resource_name(controller)
      resource_description = Apipie::ResourceDescription.new(controller, resource_name, &block)
      version = get_resource_version(resource_description)

      @resource_descriptions[version] ||= {}
      Apipie.debug("@resource_descriptions[#{version}][#{resource_name}] = #{resource_description}")
      @resource_descriptions[version][resource_name] ||= resource_description
    end

    def add_method_description_args(method, path, desc)
      @last_api_args << MethodDescription::Api.new(method, path, desc)
    end

    def add_example(example)
      @last_examples << example.strip_heredoc
    end

    # check if there is some saved description
    def apipie_provided?
      true unless last_api_args.blank?
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
        if crumbs.size == 2
          resource_description = get_resource_description(resource_name)
        elsif crumbs.size == 3
          method_name = crumbs.pop
          resource_description = get_resource_description(crumbs.join('#'))
        end
      elsif resource_name.respond_to? :apipie_resource_description
        resource_description = get_resource_description(resource_name)
      else
        raise ArgumentError.new("Resource #{resource_name} does not exists.")
      end
      unless resource_description.nil?
        resource_description._methods[method_name.to_sym]
      end
    end
    alias :[] :get_method_description

    # options:
    # => "users"
    # => "v2#users"
    # =>  V2::UsersController
    def get_resource_description(resource)
      if resource.is_a?(String)
        crumbs = resource.split('#')
        if crumbs.size == 1
          @resource_descriptions[Apipie.configuration.default_version][resource]
        elsif crumbs.size == 2 && @resource_descriptions.has_key?(crumbs.first)
          @resource_descriptions[crumbs.first][crumbs.last]
        end
      elsif resource.respond_to?(:apipie_resource_description)
        return nil if resource == ActionController::Base
        resource.apipie_resource_description
      end
    end

    def remove_method_description(resource, method_name)
      resource_description = get_resource_description(resource)
      if resource_description && resource_description._methods.has_key?(method_name)
        resource_description._methods.delete method_name
      end
    end

    # Clear all apis in this application.
    def clear
      @resource_descriptions.clear
      @method_descriptions.clear
    end

    # clear all saved data
    def clear_last
      @last_api_args = []
      @last_errors = []
      @last_params = []
      @last_description = nil
      @last_examples = []
      @last_see = nil
      @last_formats = []
    end

    # Return the current description, clearing it in the process.
    def get_description
      desc = @last_description
      @last_description = nil
      desc
    end

    def get_errors
      errors = @last_errors.clone
      @last_errors.clear
      errors
    end

    def get_api_args
      api_args = @last_api_args.clone
      @last_api_args.clear
      api_args
    end

    def get_see
      see = @last_see
      @last_see = nil
      see
    end

    def get_formats
      formats = @last_formats
      @last_formats = nil
      formats
    end

    def get_params
      params = @last_params.clone
      @last_params.clear
      params
    end

    def get_examples
      examples = @last_examples.clone
      @last_examples.clear
      examples
    end

    def recorded_examples
      return @recorded_examples if @recorded_examples
      tape_file = File.join(Rails.root,"doc","apipie_examples.yml")
      if File.exists?(tape_file)
        @recorded_examples = YAML.load_file(tape_file)
      else
        @recorded_examples = {}
      end
      @recorded_examples
    end

    def reload_examples
      @recorded_examples = nil
    end

    def to_json(version, resource_name, method_name)

      _resources = if resource_name.blank?
        # take just resources which have some methods because
        # we dont want to show eg ApplicationController as resource
        resource_descriptions[version].inject({}) do |result, (k,v)|
          result[k] = v.to_json unless v._methods.blank?
          result
        end
      else
        [@resource_descriptions[version][resource_name].to_json(method_name)]
      end

      url_args = Apipie.configuration.version_in_url ? version : ''

      {
        :docs => {
          :name => Apipie.configuration.app_name,
          :info => Apipie.app_info(version),
          :copyright => Apipie.configuration.copyright,
          :doc_url => Apipie.full_url(url_args),
          :api_url => Apipie.api_base_url(version),
          :resources => _resources
        }
      }
    end

    def api_controllers_paths
      Dir[Apipie.configuration.api_controllers_matcher]
    end

    def reload_documentation
      reload_examples
      api_controllers_paths.each do |f|
        load_controller_from_file f
      end
    end

    # Is there a reason to interpret the DSL for this run?
    # with specific setting for some environment there is no reason the dsl
    # should be interpreted (e.g. no validations and doc from cache)
    def active_dsl?
      Apipie.configuration.validate? || ! Apipie.configuration.use_cache? || Apipie.configuration.force_dsl?
    end

    private

    def get_resource_name(klass)
      if klass.class == String
        klass
      elsif klass.respond_to?(:controller_name)
        return nil if klass == ActionController::Base
        klass.controller_name
      else
        raise "Apipie: Can not resolve resource #{klass} name."
      end
    end

    def get_resource_version(resource_description)
      if resource_description.respond_to? :_version
        resource_description._version
      else
        Apipie.configuration.default_version
      end
    end

    def load_controller_from_file(controller_file)
      controller_class_name = controller_file.gsub(/\A.*\/app\/controllers\//,"").gsub(/\.\w*\Z/,"").camelize
      controller_class_name.constantize
    end

    def ignored?(controller, method = nil)
      ignored = Apipie.configuration.ignored
      return true if ignored.include?(controller.name)
      return true if ignored.include?("#{controller.name}##{method}")
    end

  end
end
