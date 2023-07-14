class Apipie::Generator::Swagger::MethodDescription::ResponseService
  # @param [Apipie::Generator::Swagger::MethodDescription::Decorator] method_description
  # @param [Symbol] http_method
  def initialize(method_description, http_method:, language:)
    @method_description = method_description
    @http_method = http_method
    @language = language
  end

  # @return [Hash]
  def call
    result = {}
    result.merge!(errors)
    result.merge!(responses)
    result.merge!(empty_returns)

    result
  end

  private

  # @return [Hash]
  def errors
    @errors ||= @method_description.errors.each_with_object({}) do |error, errors|
      errors[error.code] = {
        description: Apipie.app.translate(error.description, @language)
      }
    end
  end

  # @return [Hash]
  def responses
    @responses ||=
      @method_description.returns.each_with_object({}) do |response, responses_schema|
        responses_schema[response.code] = {
          description: Apipie.app.translate(response.description, @language),
          schema: Apipie::Generator::Swagger::MethodDescription::ResponseSchemaService.new(
            response,
            allow_null: false,
            http_method: @http_method,
            controller_method: @method_description
          ).to_swagger
        }.compact
      end
  end

  # @return [Hash]
  def empty_returns
    return {} if errors.present? || responses.present?

    Apipie::Generator::Swagger::Warning.for_code(
      Apipie::Generator::Swagger::Warning::NO_RETURN_CODES_SPECIFIED_CODE,
      @method_description.ruby_name
    ).warn_through_writer

    { 200 => { description: 'ok' } }
  end
end
