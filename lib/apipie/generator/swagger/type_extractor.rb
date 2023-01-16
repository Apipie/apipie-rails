class Apipie::Generator::Swagger::TypeExtractor
  TYPES = {
    numeric: 'number',
    hash: 'object',
    array: 'array',
    enum: 'enum',

    # see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#data-types
    integer: Apipie::Generator::Swagger::Type.new('integer', 'int32'),
    long: Apipie::Generator::Swagger::Type.new('integer', 'int64'),
    number: Apipie::Generator::Swagger::Type.new('number'),
    float: Apipie::Generator::Swagger::Type.new('number', 'float'),
    double: Apipie::Generator::Swagger::Type.new('number', 'double'),
    string: Apipie::Generator::Swagger::Type.new('string'),
    byte: Apipie::Generator::Swagger::Type.new('string', 'byte'),
    binary: Apipie::Generator::Swagger::Type.new('string', 'binary'),
    boolean: Apipie::Generator::Swagger::Type.new('boolean'),
    date: Apipie::Generator::Swagger::Type.new('string', 'date'),
    dateTime: Apipie::Generator::Swagger::Type.new('string', 'date-time'),
    password: Apipie::Generator::Swagger::Type.new('string', 'password')
  }

  # @param [Apipie::Validator::BaseValidator, ResponseDescriptionAdapter::PropDesc::Validator, nil] validator
  def initialize(validator)
    @validator = validator
  end

  # @param [Hash<Symbol, Apipie::Generator::Swagger::Warning>] warnings
  def extract_with_warnings(warnings = {})
    if boolean? && warnings[:boolean].present?
      Apipie::Generator::Swagger::WarningWriter.instance.warn(warnings[:boolean])
    end

    extract
  end

  private

  def extract
    expected_type =
      if string?
        :string
      elsif boolean?
        :boolean
      elsif enum?
        :enum
      else
        @validator.expected_type.to_sym
      end

    TYPES[expected_type] || @validator.expected_type
  end

  def string?
    @validator.blank?
  end

  def enum?
    @validator.is_a?(Apipie::Validator::EnumValidator) ||
      (@validator.respond_to?(:is_enum?) && @validator.is_enum?)
  end

  def boolean?
    @_boolean ||= enum? && boolean_values?
  end

  def boolean_values?
    @validator.values.to_set == Set.new([true, false])
  end
end
