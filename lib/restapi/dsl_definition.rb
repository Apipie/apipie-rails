# Restapi DSL functions.

module Restapi

  # DSL is a module that provides #api, #error, #param, #error.  Use this
  # when you'd like to use restapi outside the top level scope.

  module DSL

    private

    # Declare an api.
    #
    # Example:
    #   api :desc => "short description",
    #       :path => "/resource_route",
    #       :method => "GET"
    #
    def api(args)
      Restapi.application.last_api_args = args
    end

    # Describe the next method.
    #
    # Example:
    #   desc "print hello world"
    #   def hello_world
    #     puts "hello world"
    #   end
    #
    def desc(description)
      if Restapi.application.last_description
        raise "Double method description."
      end
      Restapi.application.last_description = description
    end

    # Describe possible errors
    #
    # Example:
    #   error :desc => "speaker is sleeping", :code => 500
    #   def hello_world
    #     return 500 if self.speaker.sleeping?
    #     puts "hello world"
    #   end
    #
    def error(args)
      Restapi.application.last_errors << args
    end
    
    # Describe method's parameter
    #
    # Example:
    #   param :greeting, String, :desc => "arbitrary text", :required => true
    #   def hello_world(greeting)
    #     puts greeting
    #   end
    #
    def param(param_name, validator, args)
      # "PARAM: " + param_name.to_s
      # " vtor: " + validator.to_s
      # " args: " + args.inspect
      
      args[:validator] = validator
      Restapi.application.last_params[param_name.to_sym] = args
    end
    
    def method_added(name)
      
      super
      
      return unless Restapi.application.restapi_provided?
      
      # puts "#{name} added to #{self}"
      
      unless @restapi_methods
        @restapi_methods = Hash.new
        class << self; attr_accessor :restapi_methods; end
      end
      
      name = name.to_sym

      method_name = [self, name]
      
      api = Restapi::Api.define_api(method_name)
      
      @restapi_methods[method_name] = api

      # redefine method
      # TODO: validations
      old_method = instance_method(name) 
  
      define_method(name) do |*args|
        puts "about to call #{name}(#{params})"
        
        # check if required parameters are present
        api.params.each do |key, value|
          if value[:required] && !params.has_key?(key)
            raise ArgumentError.new("Expecting #{key} parameter.")
          end
        end

        old_method.bind(self).call(*args)  
      end
      
    end
    
  end

end