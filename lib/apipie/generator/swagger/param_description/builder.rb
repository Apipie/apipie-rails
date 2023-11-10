class Apipie::Generator::Swagger::ParamDescription::Builder
  # @param [Apipie::ParamDescription] param_description
  # @param [TrueClass, FalseClass] in_schema
  # @param [Apipie::MethodDescription] controller_method
  def initialize(param_description, in_schema:, controller_method:)
    @param_description = param_description
    @in_schema = in_schema
    @controller_method = controller_method
  end

  # @param [String, nil] prefix
  def with_name(prefix: nil)
    @name = Apipie::Generator::Swagger::ParamDescription::Name.
      new(@param_description, prefixed_by: prefix)

    self
  end

  # @param [String] language
  def with_description(language:)
    @description = Apipie::Generator::Swagger::ParamDescription::Description.
      new(@param_description, language: language)

    self
  end

  # @param [TrueClass, FalseClass] with_null
  def with_type(with_null:)
    @type = Apipie::Generator::Swagger::ParamDescription::Type.
      new(@param_description, with_null: with_null, controller_method: @controller_method)

    self
  end

  def with_in(http_method:, default_in_value: nil)
    @in = Apipie::Generator::Swagger::ParamDescription::In.new(
      @param_description,
      in_schema: @in_schema,
      default_in_value: default_in_value,
      http_method: http_method
    )

    self
  end

  # @return [Hash]
  def to_swagger
    definition = {}

    definition.merge!(@name.to_hash) if @name.present?
    definition.merge!(@type.to_hash) if @type.present?
    definition.merge!(@in.to_hash) if @in.present?

    definition.merge!(for_default)
    definition.merge!(for_required)
    definition.merge!(for_example)
    definition.merge!(@description.to_hash) if @description.present?

    warn_optional_without_default_value(definition)

    definition
  end

  private

  def for_required
    return {} if !required?

    {
      required: true
    }
  end

  def for_default
    return {} unless @param_description.options.key?(:default_value)

    {
      default: @param_description.options[:default_value],
    }
  end

  def for_example
    return {} unless @param_description.options.key?(:example)

    {
      example: @param_description.options[:example],
    }
  end

  def required?
    required_from_path? || @param_description.required
  end

  def required_from_path?
    @param_description.options[:added_from_path] == true
  end

  def warn_optional_without_default_value(definition)
    if !required? && !definition.key?(:default)
      method_id =
        if @param_description.is_a?(Apipie::ResponseDescriptionAdapter::PropDesc)
          @controller_method
        else
          Apipie::Generator::Swagger::MethodDescription::Decorator.new(@controller_method).ruby_name
        end

      Apipie::Generator::Swagger::Warning.for_code(
        Apipie::Generator::Swagger::Warning::OPTIONAL_WITHOUT_DEFAULT_VALUE_CODE,
        method_id,
        { parameter: @param_description.name }
      ).warn_through_writer
    end
  end
end
