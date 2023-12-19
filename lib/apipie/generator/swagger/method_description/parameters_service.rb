class Apipie::Generator::Swagger::MethodDescription::ParametersService
  # @param [Apipie::Generator::Swagger::MethodDescription::Decorator] method_description
  # @param [Apipie::Generator::Swagger::PathDecorator] path
  # @param [Symbol] http_method
  def initialize(method_description, path:, http_method:)
    @method_description = method_description
    @path = path
    @http_method = http_method
  end

  # @return [Array]
  def call
    path_params_schema + body_params_schema + header_params_schema
  end

  private

  def path_params_schema
    Apipie::Generator::Swagger::ParamDescription::PathParamsComposite.new(
      path_param_descriptions,
      Apipie::Generator::Swagger::Context.new(
        allow_null: false,
        default_in_value: 'path',
        http_method: @http_method,
        controller_method: @method_description
      )
    ).to_swagger
  end

  def body_params_schema
    if params_in_body? && body_allowed_for_current_method?
      composite = Apipie::Generator::Swagger::ParamDescription::Composite.new(
        body_param_descriptions,
        Apipie::Generator::Swagger::Context.new(
          allow_null: false,
          http_method: @http_method,
          controller_method: @method_description
        )
      )

      if Apipie.configuration.generator.swagger.json_input_uses_refs?
        composite = composite
                    .referenced("#{@method_description.operation_id}_input")
      end

      swagger_schema_for_body = composite.to_swagger

      swagger_body_param = {
        name: 'body',
        in: 'body',
        schema: swagger_schema_for_body
      }

      if swagger_schema_for_body.present?
        [swagger_body_param]
      else
        []
      end
    else
      Apipie::Generator::Swagger::ParamDescription::PathParamsComposite.new(
        body_param_descriptions,
        Apipie::Generator::Swagger::Context.new(
          allow_null: false,
          http_method: @http_method,
          controller_method: @method_description
        )
      ).to_swagger
    end
  end

  def all_params
    @all_params ||=
      begin
        param_names_from_method = @method_description.params.keys
        missing = @path.param_names - param_names_from_method

        result = @method_description.params

        missing.each do |name|
          warn_path_parameter_not_described(name, @path)

          result[name.to_sym] = Apipie::Generator::Swagger::ParamDescription
                                .create_for_missing_param(@method_description, name)
        end

        result
      end
  end

  def body_param_descriptions
    @body_param_descriptions ||= all_params
                                 .reject { |k, _| @path.param?(k) }
                                 .values
  end

  def path_param_descriptions
    @path_param_descriptions ||= all_params
                                 .select { |k, _| @path.param?(k) }
                                 .each_value { |desc| desc.required = true }
                                 .values
  end

  # @return [Array]
  def header_params_schema
    return [] if @method_description.headers.blank?

    @method_description.headers.map do |header|
      header_hash = {
        name: header[:name],
        in: 'header',
        required: header[:options][:required],
        description: header[:description],
        type: header[:options][:type] || 'string'

      }
      if header[:options][:default]
        header_hash[:default] = header[:options][:default]
      end

      header_hash
    end
  end

  def params_in_body?
    Apipie.configuration.generator.swagger.content_type_input == :json
  end

  def body_allowed_for_current_method?
    %w[get head].exclude?(@http_method)
  end

  def warn_path_parameter_not_described(name, path)
    Apipie::Generator::Swagger::Warning.for_code(
      Apipie::Generator::Swagger::Warning::PATH_PARAM_NOT_DESCRIBED_CODE,
      @method_description.ruby_name,
      { name: name, path: path }
    ).warn_through_writer
  end
end
