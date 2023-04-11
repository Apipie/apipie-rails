class Apipie::Generator::Swagger::ParamDescription::Composite
  # @param [Array<Apipie::ParamDescription>] param_descriptions
  # @param [Apipie::Generator::Swagger::Context] context
  def initialize(param_descriptions, context)
    @param_descriptions = param_descriptions
    @context = context
    @schema = {
      type: 'object',
      properties: {}
    }
    @required_params = []
  end

  def to_swagger
    return if @param_descriptions.blank?

    @param_descriptions.each do |param_description|
      validate(param_description)

      if param_description.required
        @required_params.push(param_description.name.to_sym)
      end

      param_type = Apipie::Generator::Swagger::TypeExtractor.
        new(param_description.validator).
        extract

      has_nested_params = param_type == 'object' &&
        param_description.validator.params_ordered.present?

      if has_nested_params
        schema = Apipie::Generator::Swagger::ParamDescription::Composite.new(
          param_description.validator.params_ordered,
          Apipie::Generator::Swagger::Context.new(
            allow_null: @context.allow_null?,
            http_method: @context.http_method,
            controller_method: @context.controller_method
          )
        ).to_swagger

        return if schema.blank?

        if param_description.additional_properties
          schema[:additionalProperties] = true
        end

        if param_description.is_array?
          schema = for_array(schema)
        end

        if @context.allow_null?
          schema = with_null(schema)
        end

        if schema.present?
          @schema[:properties][param_description.name.to_sym] = schema
        end
      else
        param_entry = Apipie::Generator::Swagger::ParamDescription::Builder.
          new(
            param_description,
            in_schema: @context.in_schema?,
            controller_method: @context.controller_method
          ).
          with_description(language: @context.language).
          with_type(with_null: @context.allow_null?).
          with_in(
            default_in_value: @context.default_in_value,
            http_method: @context.http_method
          ).
          to_swagger

        @schema[:properties][param_description.name.to_sym] = param_entry
      end
    end

    if !Apipie.configuration.generator.swagger.allow_additional_properties_in_response
      @schema[:additionalProperties] = false
    end

    if @required_params.length > 0
      @schema[:required] = @required_params
    end

    @schema
  end

  # @param [Symbol, String] param_type
  #
  # @return [Apipie::Generator::Swagger::ParamDescription::ReferencedComposite]
  def referenced(param_type)
    Apipie::Generator::Swagger::ParamDescription::ReferencedComposite.
      new(self, param_type)
  end

  private

  def for_array(schema)
    {
      type: 'array',
      items: schema
    }
  end

  def with_null(schema)
    # Ideally we would write schema[:type] = ["object", "null"]
    # but due to a bug in the json-schema gem, we need to use anyOf
    # see https://github.com/ruby-json-schema/json-schema/issues/404
    {
      anyOf: [ schema, { type: 'null' } ]
    }
  end

  def validate(param_description)
    if !param_description.respond_to?(:required)
      raise "Unexpected param_desc format"
    end
  end
end
