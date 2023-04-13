class Apipie::Generator::Swagger::ParamDescription::Type
  def initialize(param_description, with_null:, controller_method:)
    @param_description = param_description
    @with_null = with_null
    @controller_method = controller_method
  end

  # @return [Hash]
  def to_hash
    type_definition = {}

    case type.to_s
    when 'array'
      type_definition.merge!(for_array_type)
    when 'enum'
      type_definition.merge!(for_enum_type)
    when 'object'
      # We only get here if there is no specification
      # of properties for this object.
      type_definition.merge!(for_object_type)
      warn_hash_without_internal_typespec
    else
      type_definition.merge!({ type: type.to_s })
    end

    if @param_description.is_array?
      type_definition = {
        items: type_definition,
        type: 'array'
      }

      if @with_null
        type_definition[:type] = [type_definition[:type], 'null']
      end
    end

    if @with_null
      type_definition[:type] = [type_definition[:type], 'null']
    end

    type_definition
  end

  private

  def params_in_body_use_reference?
    Apipie.configuration.generator.swagger.json_input_uses_refs
  end

  # @return [Apipie::Generator::Swagger::Type, String]
  def type
    @_type ||= Apipie::Generator::Swagger::TypeExtractor.
      new(validator).
      extract
  end

  def for_array_type
    validator_opts = validator.param_description.options
    items_type = validator_opts[:of].to_s || validator_opts[:array_of].to_s

    if items_type == 'Hash' && params_in_body_use_reference?
      reference_name = Apipie::Generator::Swagger::OperationId.
        from(@param_description.method_description, param: @param_description.name).
        to_s

      items = {
        '$ref' => reference_name
      }
    else
      items = { type: 'string' }
    end

    enum = @param_description.options[:in]

    items[:enum] = enum if enum.present?

    {
      type: 'array',
      items: items
    }
  end

  def for_enum_type
    {
      type: 'string',
      enum: @param_description.validator.values
    }
  end

  def for_object_type
    {
      type: 'object',
      additionalProperties: true
    }
  end

  def validator
    @_validator ||= @param_description.validator
  end

  def warn_hash_without_internal_typespec
    Apipie::Generator::Swagger::Warning.for_code(
      Apipie::Generator::Swagger::Warning::HASH_WITHOUT_INTERNAL_TYPESPEC_CODE,
      @controller_method,
      { parameter: @param_description.name }
    ).warn_through_writer
  end
end
