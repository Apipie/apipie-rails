class Apipie::Generator::Swagger::ParamDescription::PathParamsComposite
  # @param [Array<Apipie::ParamDescription>] param_descriptions
  # @param [Apipie::Generator::Swagger::Context] context
  def initialize(param_descriptions, context)
    @param_descriptions = param_descriptions
    @context = context
    @result = []
  end

  # @return [Array]
  def to_swagger
    @param_descriptions.each do |desc|
      context = @context.dup

      type = Apipie::Generator::Swagger::TypeExtractor.new(desc.validator).extract

      if type == 'object' && desc.validator.params_ordered.blank?
        warn_param_ignored_in_form_data(desc.name)
        next
      end

      has_nested_params = type == 'object' &&
                          desc.validator.params_ordered.present?

      if has_nested_params
        context.add_to_prefix!(desc.name)

        out = Apipie::Generator::Swagger::ParamDescription::PathParamsComposite
              .new(desc.validator.params_ordered, context)
              .to_swagger

        @result.concat(out)
      else
        param_entry =
          Apipie::Generator::Swagger::ParamDescription::Builder
          .new(desc, in_schema: false, controller_method: context.controller_method)
          .with_description(language: context.language)
          .with_name(prefix: context.prefix)
          .with_type(with_null: context.allow_null?)
          .with_in(
            http_method: context.http_method,
            default_in_value: context.default_in_value
          ).to_swagger

        @result << param_entry
      end
    end

    @result.sort_by { |p| p[:required] ? 0 : 1 }
  end

  private

  def warn_param_ignored_in_form_data(name)
    Apipie::Generator::Swagger::Warning.for_code(
      Apipie::Generator::Swagger::Warning::PARAM_IGNORED_IN_FORM_DATA_CODE,
      @context.controller_method.ruby_name,
      { parameter: name }
    ).warn_through_writer
  end
end
