require 'ostruct'

module Restapi

  class Application

    # we need engine just for serving static assets
    class Engine < Rails::Engine
      initializer "static assets" do |app|
        # app.middleware.use ::ActionDispatch::Static, "#{root}/app/public"
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/app/public"
      end
    end

    attr_accessor :last_api_args, :last_errors, :last_params, :last_description
    attr_reader :method_descriptions, :resource_descriptions, :info
    
    def initialize  
      super
      @method_descriptions = Hash.new
      @resource_descriptions = Hash.new
      @info = Hash.new
      clear_last
    end
    
    def options
      @options ||= OpenStruct.new
    end
    
    # create new method api description
    def define_method_description(resource_name, method_name)
      resource_name = get_resource_name(resource_name)

      puts "defining api for #{resource_name}:#{method_name}"

      # create new or get existing api
      key = [resource_name, method_name].join('#')
      @method_descriptions[key] ||= Restapi::MethodDescription.new(method_name, resource_name, self)

      # add mapi key to resource api
      define_resource_description(resource_name).add_method(key)

      @method_descriptions[key]
    end

    # create new resource api description
    def define_resource_description(resource_name)
      resource_name = get_resource_name(resource_name)

      @resource_descriptions[resource_name] ||= Restapi::ResourceDescription.new(resource_name, self)
    end
    
    # check if there is some saved description
    def restapi_provided?
      true unless last_api_args.blank?
    end
    
    # List of all the apis defined in the given scope (and its sub-scopes).
    # def mapis_for_resource(resource_name)
      # @method_descriptions.select { |key,val| key.first == controller_name }
    # end

    # get api for given method
    def get_method_description(resource_name, method_name)
      resource_name = get_resource_name(resource_name)

      @method_descriptions[[resource_name, method_name].join('#')]
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
      @last_api_args = nil
      @last_errors = Array.new
      @last_params = Hash.new
      @last_description = nil
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
    
    def get_params
      params = @last_params.clone
      @last_params.clear
      params
    end

    private

      def get_resource_name(klass)
        if klass.class == String
          klass
        elsif klass.class == Class && klass.ancestors.include?(ActionController::Base)
          klass.controller_name
        end
      end

  end
end