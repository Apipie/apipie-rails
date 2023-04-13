class Apipie::Generator::Swagger::WarningWriter
  include Singleton

  def initialize
    @issued_warnings = []
  end

  # @param [Apipie::Generator::Swagger::Warning] warning
  def warn(warning)
    return if muted_warning?(warning)

    warning.warn

    @issued_warnings << warning.id
  end

  def issued_warnings?
    @issued_warnings.count > 0
  end

  def clear!
    @issued_warnings = []

    self
  end

  private

  # @param [Apipie::Generator::Swagger::Warning] warning
  #
  # @return [TrueClass, FalseClass]
  def muted_warning?(warning)
    @issued_warnings.include?(warning.id) ||
      suppressed_warning?(warning.code) ||
      suppress_warnings?
  end

  # @param [Integer] warning_number
  #
  # @return [TrueClass, FalseClass]
  def suppressed_warning?(warning_number)
    suppress_warnings_config.is_a?(Array) && suppress_warnings_config.include?(warning_number)
  end

  # @return [TrueClass, FalseClass]
  def suppress_warnings?
    suppress_warnings_config == true
  end

  # @return [FalseClass, TrueClass, Array]
  def suppress_warnings_config
    Apipie.configuration.generator.swagger.suppress_warnings
  end
end
