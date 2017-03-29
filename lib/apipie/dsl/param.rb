module Apipie

  # DSL is a module that provides #api, #error, #param, #error.
  module DSL

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

      # where the group definition should be looked up when no scope
      # given. This is expected to return a controller.
      def _default_param_group_scope
        self
      end
    end

  end # module DSL
end # module Apipie
