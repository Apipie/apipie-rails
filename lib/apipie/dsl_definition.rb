# Apipie DSL functions.

module Apipie

  # DSL is a module that provides #api, #error, #param, #returns.
  module DSL

    module Base
      attr_reader :apipie_resource_descriptions, :api_params

      def _apipie_eval_dsl(*args, &block)
        raise 'The Apipie DLS data need to be cleared before evaluating new block' if @_apipie_dsl_data
        instance_exec(*args, &block)
        return _apipie_dsl_data
      ensure
        _apipie_dsl_data_clear
      end

      private

      def _apipie_dsl_data
        @_apipie_dsl_data ||= _apipie_dsl_data_init
      end

      def _apipie_dsl_data_clear
        @_apipie_dsl_data = nil
      end

      def _apipie_dsl_data_init
        @_apipie_dsl_data =  {
         :api               => false,
         :api_args          => [],
         :api_from_routes   => nil,
         :errors            => [],
         :tag_list          => [],
         :returns           => {},
         :params            => [],
         :headers           => [],
         :resource_id       => nil,
         :short_description => nil,
         :description       => nil,
         :examples          => [],
         :see               => [],
         :formats           => nil,
         :api_versions      => [],
         :meta              => nil,
         :show              => true,
         :deprecated        => false
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

      def deprecated(value)
        _apipie_dsl_data[:deprecated] = value
      end

    end

    module Action

      def def_param_group(name, &block)
        Apipie.add_param_group(self, name, &block)
      end

      #
      #   # load paths from routes and don't provide description
      #   api
      #
      def api(method, path, desc = nil, options={}) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:api] = true
        _apipie_dsl_data[:api_args] << [method, path, desc, options]
      end

      #   # load paths from routes
      #   api! "short description",
      #
      def api!(desc = nil, options={}) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:api] = true
        _apipie_dsl_data[:api_from_routes] = { :desc => desc, :options =>options }
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

      # Determine if the method should be included
      # in the documentation
      def show(show)
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:show] = show
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

      # describe next method with document in given path
      # in convension, these doc located under "#{Rails.root}/doc"
      # Example:
      # document "hello_world.md"
      # def hello_world
      #   puts "hello world"
      # end
      def document path
        content = File.open(File.join(Rails.root,  Apipie.configuration.doc_path, path)).read
        desc content
      end

      # Describe available request/response formats
      #
      #   formats ['json', 'jsonp', 'xml']
      def formats(formats) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:formats] = formats
      end

      # Describe additional metadata
      #
      #   meta :author => { :name => 'John', :surname => 'Doe' }
      def meta(meta) #:doc:
        _apipie_dsl_data[:meta] = meta
      end


      # Describe possible errors
      #
      # Example:
      #   error :desc => "speaker is sleeping", :code => 500, :meta => [:some, :more, :data]
      #   error 500, "speaker is sleeping"
      #   def hello_world
      #     return 500 if self.speaker.sleeping?
      #     puts "hello world"
      #   end
      #
      def error(code_or_options, desc=nil, options={}) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:errors] << [code_or_options, desc, options]
      end

      # Add tags to resources and actions group operations together.
      def tags(*args)
        return unless Apipie.active_dsl?
        tags = args.length == 1 ? args.first : args
        _apipie_dsl_data[:tag_list] += tags
      end

      def _apipie_define_validators(description)

        # [re]define method only if validation is turned on
        if description && (Apipie.configuration.validate == true ||
                           Apipie.configuration.validate == :implicitly ||
                           Apipie.configuration.validate == :explicitly)

          _apipie_save_method_params(description.method, description.params)

          unless instance_methods.include?(:apipie_validations)
            define_method(:apipie_validations) do
              method_params = self.class._apipie_get_method_params(action_name)

              if Apipie.configuration.validate_presence?
                method_params.each do |_, param|
                  # check if required parameters are present
                  raise ParamMissing.new(param) if param.required && !params.has_key?(param.name)
                end
              end

              if Apipie.configuration.validate_value?
                method_params.each do |_, param|
                  # params validations
                  param.validate(params[:"#{param.name}"]) if params.has_key?(param.name)
                end
              end

              # Only allow params passed in that are defined keys in the api
              # Auto skip the default params (format, controller, action)
              if Apipie.configuration.validate_key?
                params.reject{|k,_| %w[format controller action].include?(k.to_s) }.each_pair do |param, _|
                  # params allowed
                  if method_params.select {|_,p| p.name.to_s == param.to_s}.empty?
                    self.class._apipie_handle_validate_key_error params, param
                  end
                end
              end

              if Apipie.configuration.process_value?
                @api_params ||= {}
                method_params.each do |_, param|
                  # params processing
                  @api_params[param.as] = param.process_value(params[:"#{param.name}"]) if params.has_key?(param.name)
                end
              end
            end
          end

          if (Apipie.configuration.validate == :implicitly || Apipie.configuration.validate == true)
            old_method = instance_method(description.method)

            define_method(description.method) do |*args|
              apipie_validations

              # run the original method code
              old_method.bind(self).call(*args)
            end
          end

        end
      end

      def _apipie_handle_validate_key_error params, param
        if Apipie.configuration.action_on_non_validated_keys == :raise
          raise UnknownParam, param
        elsif Apipie.configuration.action_on_non_validated_keys == :skip
          params.delete(param)
          Rails.logger.warn(UnknownParam.new(param).to_s)
        end
      end

      def _apipie_save_method_params(method, params)
        @method_params ||= {}
        @method_params[method] = params
      end

      def _apipie_get_method_params(method)
        @method_params[method]
      end

      # Describe request header.
      #  Headers can't be validated with config.validate_presence = true
      #
      # Example:
      #   header 'ClientId', "client-id"
      #   def show
      #     render :text => headers['HTTP_CLIENT_ID']
      #   end
      #
      def header(header_name, description, options = {}) #:doc
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:headers] << {
          name: header_name,
          description: description,
          options: options
        }
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

      def property(param_name, validator, desc_or_options = nil, options = {}, &block) #:doc:
        return unless Apipie.active_dsl?
        options[:only_in] ||= :response
        options[:required] = true if options[:required].nil?
        param(param_name, validator, desc_or_options, options, &block)
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

        @_current_param_group = {
          :scope => scope,
          :name => name,
          :options => options,
          :from_concern => scope.apipie_concern?
        }
        self.instance_exec(&Apipie.get_param_group(scope, name))
      ensure
        @_current_param_group = nil
      end

      # Describe possible responses
      #
      # Example:
      #     def_param_group :user do
      #       param :user, Hash do
      #         param :name, String
      #       end
      #     end
      #
      #   returns :user, "the speaker"
      #   returns "the speaker" do
      #        param_group: :user
      #   end
      #   returns :param_group => :user, "the speaker"
      #   returns :user, :code => 201, :desc => "the created speaker record"
      #   returns :array_of => :user, "many speakers"
      #   def hello_world
      #     render json: {user: {name: "Alfred"}}
      #   end
      #
      def returns(pgroup_or_options, desc_or_options=nil, options={}, &block) #:doc:
        return unless Apipie.active_dsl?


        if desc_or_options.is_a? Hash
          options.merge!(desc_or_options)
        elsif !desc_or_options.nil?
          options[:desc] = desc_or_options
        end

        if pgroup_or_options.is_a? Hash
          options.merge!(pgroup_or_options)
        else
          options[:param_group] = pgroup_or_options
        end

        code = options[:code] || 200
        scope = options[:scope] || _default_param_group_scope
        descriptor = options[:param_group] || options[:array_of]

        if block.nil?
          if descriptor.is_a? ResponseDescriptionAdapter
            adapter = descriptor
          elsif descriptor.respond_to? :describe_own_properties
            adapter = ResponseDescriptionAdapter.from_self_describing_class(descriptor)
          else
            begin
              block = Apipie.get_param_group(scope, descriptor) if descriptor
            rescue
              raise "No param_group or self-describing class named #{descriptor}"
            end
          end
        elsif descriptor
          raise "cannot specify both block and param_group"
        end

        _apipie_dsl_data[:returns][code] = [options, scope, block, adapter]
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

      # Allows to update existing params after definition was made (usually needed
      # when extending the API form plugins).
      #
      #     UsersController.apipie_update_params([:create, :update]) do
      #       param :user, Hash do
      #         param :oauth, String
      #       end
      #      end
      #
      # The block is evaluated in scope of the controller. Ohe can pass some additional
      # objects via additional arguments like this:
      #
      #     UsersController.apipie_update_params([:create, :update], [:name, :secret]) do |param_names|
      #       param :user, Hash do
      #         param_names.each { |p| param p, String }
      #       end
      #      end
      def _apipie_update_params(method_desc, dsl_data)
        params_ordered = dsl_data[:params].map do |args|
          Apipie::ParamDescription.from_dsl_data(method_desc, args)
        end
        ParamDescription.merge(method_desc.params_ordered_self, params_ordered)
      end

      def _apipie_update_meta(method_desc, dsl_data)
        return unless dsl_data[:meta] && dsl_data[:meta].is_a?(Hash)

        method_desc.metadata ||= {}
        method_desc.metadata.merge!(dsl_data[:meta])
      end

      def apipie_update_methods(methods, *args, &block)
        methods.each do |method|
          method_desc = Apipie.get_method_description(self, method)
          unless method_desc
            raise "Could not find method description for #{self}##{method}. Was the method defined?"
          end
          dsl_data = _apipie_eval_dsl(*args, &block)
          _apipie_update_params(method_desc, dsl_data)
          _apipie_update_meta(method_desc, dsl_data)
        end
      end
      # backwards compatibility
      alias_method :apipie_update_params, :apipie_update_methods

      def _apipie_concern_subst
        @_apipie_concern_subst ||= {:controller_path => self.controller_path,
                                    :resource_id => Apipie.get_resource_name(self)}
      end

      def _apipie_perform_concern_subst(string)
        return _apipie_concern_subst.reduce(string) do |ret, (key, val)|
          ret.gsub(":#{key}", val)
        end
      end

      def apipie_concern?
        false
      end

      # create method api and redefine newly added method
      def method_added(method_name) #:doc:
        super
        return if !Apipie.active_dsl? || !_apipie_dsl_data[:api]

        return if _apipie_dsl_data[:api_args].blank? && _apipie_dsl_data[:api_from_routes].blank?

        # remove method description if exists and create new one
        Apipie.remove_method_description(self, _apipie_dsl_data[:api_versions], method_name)
        description = Apipie.define_method_description(self, method_name, _apipie_dsl_data)

        _apipie_dsl_data_clear
        _apipie_define_validators(description)
      ensure
        _apipie_dsl_data_clear
      end
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
        _apipie_concern_update_api_blocks.each do |(methods, block)|
          controller.apipie_update_methods(methods, &block)
        end
      end

      def _apipie_concern_data
        @_apipie_concern_data ||= []
      end

      def _apipie_concern_update_api_blocks
        @_apipie_concern_update_api_blocks ||= []
      end

      def apipie_concern?
        true
      end

      # create method api and redefine newly added method
      def method_added(method_name) #:doc:
        super

        return if ! Apipie.active_dsl? || !_apipie_dsl_data[:api]

        _apipie_concern_data << [method_name, _apipie_dsl_data.merge(:from_concern => true)]
      ensure
        _apipie_dsl_data_clear
      end

      def update_api(*methods, &block)
        _apipie_concern_update_api_blocks << [methods, block]
      end

    end

    class ResourceDescriptionDsl
      include Apipie::DSL::Base
      include Apipie::DSL::Common
      include Apipie::DSL::Resource
      include Apipie::DSL::Param

      def initialize(controller)
        @controller = controller
      end

      # evaluates resource description DSL and returns results
      def self.eval_dsl(controller, &block)
        dsl_data  = self.new(controller)._apipie_eval_dsl(&block)
        if dsl_data[:api_versions].empty?
          dsl_data[:api_versions] = Apipie.controller_versions(controller)
        end
        dsl_data
      end
    end

  end # module DSL
end # module Apipie
