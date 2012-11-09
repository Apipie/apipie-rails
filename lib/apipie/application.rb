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
    attr_reader :method_descriptions, :resource_descriptions

    def initialize
      super
      @method_descriptions = Hash.new
      @resource_descriptions = Hash.new
      clear_last
    end

    # create new method api description
    def define_method_description(controller, method_name)
      # create new or get existing api
      resource_name = get_resource_name(controller)
      if ignored?(controller, method_name)
        clear_last
        return
      end

      key = [resource_name, method_name].join('#')
      # add method description key to resource description
      resource = define_resource_description(controller)

      method_description = Apipie::MethodDescription.new(method_name, resource, self)

      @method_descriptions[key] ||= method_description

      @method_descriptions[key]
    end

    # create new resource api description
    def define_resource_description(controller, &block)
      if ignored?(controller)
        clear_last
        return
      end

      resource_name = get_resource_name(controller)

      # puts "defining api for #{resource_name}"

      @resource_descriptions[resource_name] ||=
        Apipie::ResourceDescription.new(controller, resource_name, &block)
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
    #   resource_name: controller class or string with resource name (plural)
    #   method_name: name of the method (string or symbol)
    # 2) Specify only first parameter:
    #   resource_name: string containing both resource and method name joined
    #   with # (eg. "users#create")
    def get_method_description(resource_name, method_name = nil)
      resource_name = get_resource_name(resource_name)
      key = method_name.blank? ? resource_name : [resource_name, method_name].join('#')
      @method_descriptions[key]
    end
    alias :[] :get_method_description

    # get api for given resource
    def get_resource_description(resource_name)
      resource_name = get_resource_name(resource_name)

      @resource_descriptions[resource_name]
    end

    def remove_method_description(resource_name, method_name)
      resource_name = get_resource_name(resource_name)

      @method_descriptions.delete [resource_name, method_name].join('#')
    end

    def remove_resource_description(resource_name)
      resource_name = get_resource_name(resource_name)

      @resource_descriptions.delete resource_name
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

    def to_json(resource_name, method_name)

      _resources = if resource_name.blank?
        # take just resources which have some methods because
        # we dont want to show eg ApplicationController as resource
        resource_descriptions.inject({}) do |result, (k,v)|
          result[k] = v.to_json unless v._methods.blank?
          result
        end
      else
        [@resource_descriptions[resource_name].to_json(method_name)]
      end

      {
        :docs => {
          :name => Apipie.configuration.app_name,
          :info => Apipie.configuration.app_info,
          :copyright => Apipie.configuration.copyright,
          :doc_url => Apipie.full_url(""),
          :api_url => Apipie.configuration.api_base_url,
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
        klass.controller_name
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
