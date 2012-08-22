# Apipie DSL functions.

module Apipie

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
      return unless Apipie.active_dsl?
      Apipie.remove_resource_description(self)
      Apipie.define_resource_description(self, &block) if block_given?
    end

    # Declare an api.
    #
    # Example:
    #   api :GET, "/resource_route", "short description",
    #
    def api(method, path, desc = nil) #:doc:
      return unless Apipie.active_dsl?
      Apipie.add_method_description_args(method, path, desc)
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
      return unless Apipie.active_dsl?
      if Apipie.last_description
        raise "Double method description."
      end
      Apipie.last_description = description
    end
    alias :description :desc

    # Reference other similar method
    #
    #   api :PUT, '/articles/:id'
    #   see "articles#create"
    #   def update; end
    def see(method_key)
      return unless Apipie.active_dsl?
      raise "'See' method called twice." if Apipie.last_see
      Apipie.last_see = method_key
    end

    # Show some example of what does the described
    # method return.
    def example(example) #:doc:
      return unless Apipie.active_dsl?
      Apipie.add_example(example)
    end

    # Describe available request/response formats
    #
    #   formats ['json', 'jsonp', 'xml']
    def formats(formats) #:doc:
      return unless Apipie.active_dsl?
      Apipie.last_formats = formats
    end

    # Describe possible errors
    #
    # Example:
    #   error :desc => "speaker is sleeping", :code => 500
    #   error 500, "speaker is sleeping"
    #   def hello_world
    #     return 500 if self.speaker.sleeping?
    #     puts "hello world"
    #   end
    #
    def error(*args) #:doc:
      return unless Apipie.active_dsl?
      Apipie.last_errors << Apipie::ErrorDescription.new(args)
    end

    # Describe method's parameter
    #
    # Example:
    #   param :greeting, String, :desc => "arbitrary text", :required => true
    #   def hello_world(greeting)
    #     puts greeting
    #   end
    #
    def param(param_name, validator, desc_or_options = nil, options = {}, &block) #:doc:
      return unless Apipie.active_dsl?
      Apipie.last_params << Apipie::ParamDescription.new(param_name, validator, desc_or_options, options, &block)
    end

    # create method api and redefine newly added method
    def method_added(method_name) #:doc:
      super

      return unless Apipie.active_dsl?
      return unless Apipie.apipie_provided?

      # remove method description if exists and create new one
      Apipie.remove_method_description(self, method_name)
      description = Apipie.define_method_description(self, method_name)

      # redefine method only if validation is turned on
      if Apipie.configuration.validate == true

        old_method = instance_method(method_name)

        define_method(method_name) do |*args|

          if Apipie.configuration.validate == true
            description.params.each do |_, param|

              # check if required parameters are present
              if param.required && !params.has_key?(param.name)
                raise ParamMissing.new(param.name)
              end

              # params validations
              if params.has_key?(param.name)
                param.validate(params[:"#{param.name}"])
              end

            end
          end

          # run the original method code
          old_method.bind(self).call(*args)
        end

      end

    end # def method_added
  end # module DSL
end # module Apipie
