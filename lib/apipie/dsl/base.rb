# Apipie DSL functions.
module Apipie

  # DSL is a module that provides #api, #error, #param, #error.
  module DSL

    module Base
      attr_reader :apipie_resource_descriptions, :api_params

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
         :responses         => [],
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
         :show              => true
       }
      end
    end

  end # module DSL
end # module Apipie
