# Restapi DSL functions.

module Restapi

  # DSL is a module that provides #api, #error, #param, #error.
  module DSL

    private
    
    # Describe whole resource
    # 
    # Example:
    # api :desc => "Show user profile", :path => "/users/", :version => '1.0 - 3.4.2012'
    # param :id, Fixnum, :desc => "User ID", :required => true
    # desc <<-EOS
    #   Long description...
    # EOS
    def resource_description(options = {}, &block) #:doc:
      Restapi.remove_resource_description(self)
      Restapi.define_resource_description(self, &block) if block_given?
    end

    # Declare an api.
    #
    # Example:
    #   api :GET, "/resource_route", "short description",
    #
    def api(method, path, desc = nil) #:doc:
      Restapi.add_method_description_args(method, path, desc)
    end

    # Describe the next method.
    #
    # Example:
    #   desc "print hello world"
    #   def hello_world
    #     puts "hello world"
    #   end
    #
    def desc(description) #:doc:
      if Restapi.last_description
        raise "Double method description."
      end
      Restapi.last_description = description
    end
    alias :description :desc

    # Show some example of what does the described 
    # method return.
    def example(example) #:doc:
      Restapi.add_example(example)
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
    def error(args) #:doc:
      Restapi.last_errors << Restapi::ErrorDescription.new(args)
    end
    
    # Describe method's parameter
    #
    # Example:
    #   param :greeting, String, :desc => "arbitrary text", :required => true
    #   def hello_world(greeting)
    #     puts greeting
    #   end
    #
    def param(param_name, *args, &block) #:doc:
      Restapi.last_params << Restapi::ParamDescription.new(param_name, *args, &block)
    end
    
    # create method api and redefine newly added method
    def method_added(method_name) #:doc:s

      super
      
      return unless Restapi.restapi_provided?
      
      # remove method description if exists and create new one
      Restapi.remove_method_description(self, method_name)
      description = Restapi.define_method_description(self, method_name)

      # redefine method only if validation is turned on
      if Restapi.configuration.validate == true

        old_method = instance_method(method_name) 
        
        define_method(method_name) do |*args|
          
          description.params.each do |_, param|

            # check if required parameters are present
            if param.required && !params.has_key?(param.name)
              raise ArgumentError.new("Expecting #{param.name} parameter.")
            end
            
            # params validations
            if params.has_key?(param.name)
              param.validate(params[:"#{param.name}"])
            end

          end # params.each

          # run the original method code
          old_method.bind(self).call(*args)
        end

      end
      
    end # def method_added
  end # module DSL
end # module Restapi
