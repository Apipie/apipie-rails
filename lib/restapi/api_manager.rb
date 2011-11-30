
module Restapi

  module ApiManager
    
    attr_accessor :last_api_args
    attr_accessor :last_errors
    attr_accessor :last_params
    attr_accessor :last_description
    
    def initialize
      
      super
      @apis = Hash.new
      
      @last_api_args = nil
      @last_errors = Array.new
      @last_params = Hash.new
      @last_description = nil
    end
    
    def define_api(api_class, method_name)

      puts "defining api for method " + method_name.to_s + " hash: " + method_name.hash.to_s
      
      # create new or get existing api
      @apis[method_name] ||= api_class.new(method_name, self)
      
    end
    
    def restapi_provided?
      true if last_description
    end
    
    # List of all defined apis in this application.
    def apis
      @apis
    end
    
    # List of all the apis defined in the given scope (and its sub-scopes).
    def apis_for_controller(controller_name)
      @apis.select { |t| controller_name == t.method_name.first }
    end

    # get api for given controoler and method name
    def get_api(controller, method_name)
      id = [controller, method_name]
      
      api = @apis[id]

      api or fail "Don't know api for '#{method_name}'"
    end
    alias :[] :get_api

    # Clear all apis in this application.
    def clear
      @apis.clear
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
      api_args = @last_api_args
      api_args
    end
    
    def get_params
      params = @last_params.clone
      @last_params.clear
      params
    end
    
  end
  
end