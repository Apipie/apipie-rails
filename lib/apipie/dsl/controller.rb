module Apipie

  # DSL is a module that provides #api, #error, #param, #error.
  module DSL

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

  end # module DSL
end # module Apipie
