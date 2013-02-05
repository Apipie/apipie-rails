# Apipie DSL functions.

module Apipie

  # DSL is a module that provides #api, #error, #param, #error.
  module DSL

    attr_reader :apipie_resource_descriptions

    private

    def _apipie_dsl_data
      @_apipie_dsl_data ||= _apipie_dsl_data_init
    end

    def _apipie_dsl_data_clear
      @_apipie_dsl_data = nil
    end

    def _apipie_dsl_data_init
      @_apipie_dsl_data =  {
       :api_args          => [],
       :errors            => [],
       :params            => [],
       :resouce_id        => nil,
       :short_description => nil,
       :description       => nil,
       :examples          => [],
       :see               => [],
       :formats           => nil,
       :api_versions      => []
     }
    end

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
      raise ArgumentError, "Block expected" unless block_given?

      dsl_data = ResourceDescriptionDsl.eval_dsl(self, &block)
      versions = dsl_data[:api_versions]
      @apipie_resource_descriptions = versions.map do |version|
        Apipie.define_resource_description(self, version, dsl_data)
      end
      Apipie.set_controller_versions(self, versions)
    end

    class ResourceDescriptionDsl
      include Apipie::DSL

      NO_RESOURCE_KEYWORDS = %w[api see example]

      NO_RESOURCE_KEYWORDS.each do |method|
        define_method method do
          raise "#{method} is not defined for resource description"
        end
      end

      def initialize(controller)
        @controller = controller
      end

      # by default, the resource id is derived from controller_name
      # it can be overwritten with.
      #
      #    resource_id "my_own_resource_id"
      def resource_id(resource_id)
        Apipie.set_resource_id(@controller, resource_id)
      end

      def name(name)
        _apipie_dsl_data[:resource_name] = name
      end

      def api_base_url(url)
        _apipie_dsl_data[:api_base_url] = url
      end

      def short(short)
        _apipie_dsl_data[:short_description] = short
      end
      alias :short_description :short

      def path(path)
        _apipie_dsl_data[:path] = path
      end

      def app_info(app_info)
        _apipie_dsl_data[:app_info] = app_info
      end

      def _eval_dsl(&block)
        instance_eval(&block)
        return _apipie_dsl_data
      end

      # evaluates resource description DSL and returns results
      def self.eval_dsl(controller, &block)
        dsl_data  = self.new(controller)._eval_dsl(&block)
        if dsl_data[:api_versions].empty?
          dsl_data[:api_versions] = Apipie.controller_versions(controller)
        end
        dsl_data
      end
    end


    # Declare an api.
    #
    # Example:
    #   api :GET, "/resource_route", "short description",
    #
    def api(method, path, desc = nil) #:doc:
      return unless Apipie.active_dsl?
      _apipie_dsl_data[:api_args] << MethodDescription::Api.new(method, path, desc)
    end

    def api_versions(*versions)
      _apipie_dsl_data[:api_versions].concat(versions)
    end
    alias :api_version :api_versions

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
      if _apipie_dsl_data[:description]
        raise "Double method description."
      end
      _apipie_dsl_data[:description] = description
    end
    alias :description :desc
    alias :full_description :desc

    # Reference other similar method
    #
    #   api :PUT, '/articles/:id'
    #   see "articles#create"
    #   def update; end
    def see(*args)
      return unless Apipie.active_dsl?
      _apipie_dsl_data[:see] << Apipie::SeeDescription.new(args)
    end

    # Show some example of what does the described
    # method return.
    def example(example) #:doc:
      return unless Apipie.active_dsl?
      _apipie_dsl_data[:examples] << example.strip_heredoc
    end

    # Describe available request/response formats
    #
    #   formats ['json', 'jsonp', 'xml']
    def formats(formats) #:doc:
      return unless Apipie.active_dsl?
      _apipie_dsl_data[:formats] = formats
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
      _apipie_dsl_data[:errors] << Apipie::ErrorDescription.new(args)
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
      _apipie_dsl_data[:params] << Apipie::ParamDescription.new(param_name, validator, desc_or_options, options, &block)
    end

    # create method api and redefine newly added method
    def method_added(method_name) #:doc:
      super

      if ! Apipie.active_dsl? || _apipie_dsl_data[:api_args].blank?
        _apipie_dsl_data_clear
        return
      end

      begin
        # remove method description if exists and create new one
        Apipie.remove_method_description(self, _apipie_dsl_data[:api_versions], method_name)
        description = Apipie.define_method_description(self, method_name, _apipie_dsl_data)
      ensure
        _apipie_dsl_data_clear
      end

      # redefine method only if validation is turned on
      if description && Apipie.configuration.validate == true

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
