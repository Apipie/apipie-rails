class Apipie::Generator::Swagger::MethodDescription::ApiSchemaService
  # @param [Apipie::Generator::Swagger::MethodDescription::Decorator] method_description
  def initialize(method_description, language: nil)
    @method_description = method_description
    @language = language
  end

  # @return [Hash]
  def call
    @method_description.apis.each_with_object({}) do |api, paths|
      api = Apipie::Generator::Swagger::MethodDescription::ApiDecorator.new(api)
      path = Apipie::Generator::Swagger::PathDecorator.new(api.path)
      op_id = Apipie::Generator::Swagger::OperationId.from(api).to_s

      if Apipie.configuration.generator.swagger.generate_x_computed_id_field?
        Apipie::Generator::Swagger::ComputedInterfaceId.instance.add!(op_id)
      end

      parameters = Apipie::Generator::Swagger::MethodDescription::ParametersService
                   .new(@method_description, path: path, http_method: api.normalized_http_method)
                   .call

      paths[path.swagger_path(@method_description)] ||= {}
      paths[path.swagger_path(@method_description)][api.normalized_http_method] = {
        tags: tags,
        consumes: consumes,
        operationId: op_id,
        summary: api.summary(method_description: @method_description, language: @language),
        parameters: parameters,
        responses: responses(api),
        description: Apipie.app.translate(@method_description.full_description, @language)
      }.compact
    end
  end

  private

  def summary(api)
    translated_description = Apipie.app.translate(api.short_description, @language)

    return translated_description if translated_description.present?

    Apipie::Generator::Swagger::Warning.for_code(
      Apipie::Generator::Swagger::Warning::MISSING_METHOD_SUMMARY_CODE,
      @method_description.ruby_name
    ).warn_through_writer
  end

  def tags
    tags = if Apipie.configuration.generator.swagger.skip_default_tags?
             []
           else
             [@method_description.resource._id]
           end
    tags + warning_tags + @method_description.tag_list.tags
  end

  def warning_tags
    if Apipie.configuration.generator.swagger.include_warning_tags? &&
       Apipie::Generator::Swagger::WarningWriter.instance.issued_warnings?
      ['warnings issued']
    else
      []
    end
  end

  def consumes
    if params_in_body?
      ['application/json']
    else
      ['application/x-www-form-urlencoded', 'multipart/form-data']
    end
  end

  def params_in_body?
    Apipie.configuration.generator.swagger.content_type_input == :json
  end

  # @param [Apipie::Generator::Swagger::MethodDescription::ApiDecorator] api
  def responses(api)
    Apipie::Generator::Swagger::MethodDescription::ResponseService
      .new(
        @method_description,
        language: @language,
        http_method: api.normalized_http_method
      )
      .call
  end
end
