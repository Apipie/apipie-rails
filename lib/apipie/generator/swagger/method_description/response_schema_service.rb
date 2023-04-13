class Apipie::Generator::Swagger::MethodDescription::ResponseSchemaService
  # @param [Apipie::ResponseDescription, Apipie::ResponseDescriptionAdapter] response_description
  def initialize(response_description, allow_null:, http_method:, controller_method:)
    @response_description = response_description
    @allow_null = allow_null
    @http_method = http_method
    @controller_method = controller_method
  end

  def to_swagger
    composite = Apipie::Generator::Swagger::ParamDescription::Composite.new(
      @response_description.params_ordered,
      Apipie::Generator::Swagger::Context.new(
        allow_null: @allow_null,
        http_method: @http_method,
        controller_method: @controller_method
      )
    )

    if Apipie.configuration.generator.swagger.responses_use_refs? && @response_description.typename.present?
      composite = composite.referenced(@response_description.typename)
    end

    schema = composite.to_swagger

    if @response_description.is_array? && schema
      schema = { type: type_for_array, items: schema }
    end

    if @response_description.allow_additional_properties
      schema[:additionalProperties] = true
    end

    schema
  end

  private

  def type_for_array
    if @allow_null == true
      %w[array null]
    else
      'array'
    end
  end
end
