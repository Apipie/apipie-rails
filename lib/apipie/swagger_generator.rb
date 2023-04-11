module Apipie
  class SwaggerGenerator
    # @param [Array<Apipie::ResourceDescription] resources
    def self.generate_from_resources(resources, version:, language:, clear_warnings: false)
      Apipie::Generator::Swagger::Schema.new(
        resources,
        version: version,
        language: language,
        clear_warnings: clear_warnings
      ).generate
    end

    def self.json_schema_for_method_response(method, return_code, allow_nulls)
      response = method.returns.find { |response| response.code.to_s == return_code.to_s }

      return if response.blank?

      http_method = method.apis.first.http_method

      schema = Apipie::Generator::Swagger::MethodDescription::ResponseSchemaService.new(
        response,
        allow_null: allow_nulls,
        http_method: http_method,
        controller_method: method
      ).to_swagger

      definitions = Apipie::Generator::Swagger::ReferencedDefinitions.instance.definitions

      if definitions.present?
        schema[:definitions] = definitions
      end

      schema
    end

    def self.json_schema_for_self_describing_class(cls, allow_nulls)
      Apipie::Generator::Swagger::MethodDescription::ResponseSchemaService.new(
        ResponseDescriptionAdapter.from_self_describing_class(cls),
        allow_null: allow_nulls,
        http_method: nil,
        controller_method: nil
      ).to_swagger
    end
  end
end
