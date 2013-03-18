# Apipie DSL functions.

module Apipie

  # DSL is a module that provides #api, #error, #param, #error.
  module DSL

    module Base
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
    end

    module Resource
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
    end

    module Action

      def def_param_group(name, &block)
        Apipie.add_param_group(self, name, &block)
      end

      # Declare an api.
      #
      # Example:
      #   api :GET, "/resource_route", "short description",
      #
      def api(method, path, desc = nil) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:api_args] << [method, path, desc]
      end

      # Reference other similar method
      #
      #   api :PUT, '/articles/:id'
      #   see "articles#create"
      #   def update; end
      def see(*args)
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:see] << args
      end

      # Show some example of what does the described
      # method return.
      def example(example) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:examples] << example.strip_heredoc
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

    end

    module Common
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
        _apipie_dsl_data[:errors] << args
      end

      def _apipie_define_validators(description)
        # redefine method only if validation is turned on
        if description && Apipie.configuration.validate == true

          old_method = instance_method(description.method)

          define_method(description.method) do |*args|

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

      end

    end

    # this describes the params, it's in separate module because it's
    # used in Validators as well
    module Param
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
        _apipie_dsl_data[:params] << [param_name,
                                      validator,
                                      desc_or_options,
                                      options.merge(:param_group => @_current_param_group),
                                      block]
      end

      # Reuses param group for this method. The definition is looked up
      # in scope of this controller. If the group was defined in
      # different controller, the second param can be used to specify it.
      # when using action_aware parmas, you can specify :as =>
      # :create or :update to explicitly say how it should behave
      def param_group(name, scope_or_options = nil, options = {})
        if scope_or_options.is_a? Hash
          options.merge!(scope_or_options)
          scope = options[:scope]
        else
          scope = scope_or_options
        end
        scope ||= _default_param_group_scope
        @_current_param_group = {:scope => scope, :name => name, :options => options}
        self.instance_exec(&Apipie.get_param_group(scope, name))
      ensure
        @_current_param_group = nil
      end

      # where the group definition should be looked up when no scope
      # given. This is expected to return a controller.
      def _default_param_group_scope
        self
      end
    end

    module Controller
      include Apipie::DSL::Base
      include Apipie::DSL::Common
      include Apipie::DSL::Action
      include Apipie::DSL::Param

      # defines the substitutions to be made in the API paths deifned
      # in concerns included. For example:
      #
      # There is this method defined in concern:
      #
      #    api GET ':controller_path/:id'
      #    def show
      #      # ...
      #    end
      #
      # If you include the concern into some controller, you can
      # specify the value for :controller_path like this:
      #
      #      apipie_concern_subst(:controller_path => '/users')
      #      include ::Concerns::SampleController
      #
      # The resulting path will be '/users/:id'.
      #
      # It has to be specified before the concern is included.
      #
      # If not specified, the default predefined substitions are
      #
      #    {:conroller_path => controller.controller_path,
      #     :resource_id  => `resource_id_from_apipie` }
      def apipie_concern_subst(subst_hash)
        _apipie_concern_subst.merge!(subst_hash)
      end

      def _apipie_concern_subst
        @_apipie_concern_subst ||= {:controller_path => self.controller_path,
                                    :resource_id => Apipie.get_resource_name(self)}
      end

      def _apipie_perform_concern_subst(string)
        return _apipie_concern_subst.reduce(string) do |ret, (key, val)|
          ret.gsub(":#{key}", val)
        end
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

        _apipie_define_validators(description)
      end # def method_added
    end

    module Concern
      include Apipie::DSL::Base
      include Apipie::DSL::Common
      include Apipie::DSL::Action
      include Apipie::DSL::Param

      # the concern was included into a controller
      def included(controller)
        super
        _apipie_concern_data.each do |method_name, _apipie_dsl_data|
          # remove method description if exists and create new one
          description = Apipie.define_method_description(controller, method_name, _apipie_dsl_data)
          controller._apipie_define_validators(description)
        end
      end

      def _apipie_concern_data
        @_apipie_concern_data ||= []
      end

      # create method api and redefine newly added method
      def method_added(method_name) #:doc:
        super

        if ! Apipie.active_dsl? || _apipie_dsl_data[:api_args].blank?
          _apipie_dsl_data_clear
          return
        end

        begin
          _apipie_concern_data << [method_name, _apipie_dsl_data.merge(:from_concern => true)]
        ensure
          _apipie_dsl_data_clear
        end

      end # def method_added

    end

    class ResourceDescriptionDsl
      include Apipie::DSL::Base
      include Apipie::DSL::Common
      include Apipie::DSL::Resource
      include Apipie::DSL::Param

      def initialize(controller)
        @controller = controller
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

  end # module DSL
end # module Apipie
