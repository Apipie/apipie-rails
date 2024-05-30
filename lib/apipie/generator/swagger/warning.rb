class Apipie::Generator::Swagger::Warning
  MISSING_METHOD_SUMMARY_CODE = 100
  ADDED_MISSING_SLASH_CODE = 101
  NO_RETURN_CODES_SPECIFIED_CODE = 102
  HASH_WITHOUT_INTERNAL_TYPESPEC_CODE = 103
  OPTIONAL_PARAM_IN_PATH_CODE = 104
  OPTIONAL_WITHOUT_DEFAULT_VALUE_CODE = 105
  PARAM_IGNORED_IN_FORM_DATA_CODE = 106
  PATH_PARAM_NOT_DESCRIBED_CODE = 107

  CODES = {
    missing_method_summary: MISSING_METHOD_SUMMARY_CODE,
    added_missing_slash: ADDED_MISSING_SLASH_CODE,
    no_return_codes_specified: NO_RETURN_CODES_SPECIFIED_CODE,
    hash_without_internal_typespec: HASH_WITHOUT_INTERNAL_TYPESPEC_CODE,
    optional_param_in_path: OPTIONAL_PARAM_IN_PATH_CODE,
    optional_without_default_value: OPTIONAL_WITHOUT_DEFAULT_VALUE_CODE,
    param_ignored_in_form_data: PARAM_IGNORED_IN_FORM_DATA_CODE,
    path_param_not_described_code: PATH_PARAM_NOT_DESCRIBED_CODE
  }.freeze

  MESSAGES = {
    MISSING_METHOD_SUMMARY_CODE => "Missing short description for method",
    ADDED_MISSING_SLASH_CODE => "Added missing / at beginning of path: %{path}",
    HASH_WITHOUT_INTERNAL_TYPESPEC_CODE => "The parameter :%{parameter} is a generic Hash without an internal type specification",
    NO_RETURN_CODES_SPECIFIED_CODE => "No return codes ('errors') specified",
    OPTIONAL_PARAM_IN_PATH_CODE => "The parameter :%{parameter} is 'in-path'.  Ignoring 'not required' in DSL",
    OPTIONAL_WITHOUT_DEFAULT_VALUE_CODE => "The parameter :%{parameter} is optional but default value is not specified (use :default_value => ...)",
    PARAM_IGNORED_IN_FORM_DATA_CODE => "Ignoring param :%{parameter} -- cannot include Hash without fields in a formData specification",
    PATH_PARAM_NOT_DESCRIBED_CODE => "The parameter :%{name} appears in the path %{path} but is not described"
  }.freeze

  attr_reader :code

  def initialize(code, info_message, method_id)
    @code = code
    @info_message = info_message
    @method_id = method_id
  end

  def id
    "#{@method_id}#{@code}#{@info_message}"
  end

  def warning_message
    "WARNING (#{@code}): [#{@method_id}] -- #{@info_message}\n"
  end

  def warn
    Warning.warn(warning_message)
  end

  def warn_through_writer
    Apipie::Generator::Swagger::WarningWriter.instance.warn(self)
  end

  # @param [Integer] code
  # @param [Hash] message_attributes
  #
  # @return [Apipie::Generator::Swagger::Warning]
  def self.for_code(code, method_id, message_attributes = {})
    if !CODES.value?(code)
      raise ArgumentError, 'Unknown warning code'
    end

    info_message = if message_attributes.present?
                     self::MESSAGES[code] % message_attributes
                   else
                     self::MESSAGES[code]
                   end

    Apipie::Generator::Swagger::Warning.new(code, info_message, method_id)
  end
end
