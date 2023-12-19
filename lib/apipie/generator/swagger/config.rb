require 'singleton'

module Apipie
  module Generator
    module Swagger
      class Config
        include Singleton

        CONFIG_ATTRIBUTES = [:include_warning_tags, :content_type_input,
                             :json_input_uses_refs, :suppress_warnings, :api_host,
                             :generate_x_computed_id_field, :allow_additional_properties_in_response,
                             :responses_use_refs, :schemes, :security_definitions,
                             :global_security, :skip_default_tags].freeze

        attr_accessor(*CONFIG_ATTRIBUTES)

        CONFIG_ATTRIBUTES.each do |attribute|
          old_setter_method = "swagger_#{attribute}="
          define_method(old_setter_method) do |value|
            ActiveSupport::Deprecation.warn(
              <<~HEREDOC
                config.#{old_setter_method}#{value} is deprecated.
                config.generator.swagger.#{attribute} instead.
              HEREDOC
            )

            send(:"#{attribute}=", value)
          end

          old_setter_method = "swagger_#{attribute}"
          define_method(old_setter_method) do
            ActiveSupport::Deprecation.warn(
              <<~HEREDOC
                config.#{old_setter_method} is deprecated.
                Use config.generator.swagger.#{attribute} instead.
              HEREDOC
            )

            send(attribute)
          end
        end

        alias include_warning_tags? include_warning_tags
        alias json_input_uses_refs? json_input_uses_refs
        alias responses_use_refs? responses_use_refs
        alias skip_default_tags? skip_default_tags
        alias generate_x_computed_id_field? generate_x_computed_id_field
        alias swagger_include_warning_tags? swagger_include_warning_tags
        alias swagger_json_input_uses_refs? swagger_json_input_uses_refs
        alias swagger_responses_use_refs? swagger_responses_use_refs
        alias swagger_generate_x_computed_id_field? swagger_generate_x_computed_id_field

        def initialize
          @content_type_input = :form_data # this can be :json or :form_data
          @json_input_uses_refs = false
          @include_warning_tags = false
          @suppress_warnings = false # [105,100,102]
          @api_host = 'localhost:3000'
          @generate_x_computed_id_field = false
          @allow_additional_properties_in_response = false
          @responses_use_refs = true
          @schemes = [:https]
          @security_definitions = {}
          @global_security = []
          @skip_default_tags = false
        end

        def self.deprecated_methods
          CONFIG_ATTRIBUTES.map do |attribute|
            [
              :"swagger_#{attribute}=",
              :"swagger_#{attribute}?",
              :"swagger_#{attribute}"
            ]
          end.flatten
        end
      end
    end
  end
end
