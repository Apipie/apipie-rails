module Apipie

  # DSL is a module that provides #api, #error, #param, #error.
  module DSL

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

    end

  end # module DSL
end # module Apipie
