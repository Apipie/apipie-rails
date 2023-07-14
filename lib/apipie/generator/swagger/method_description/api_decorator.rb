class Apipie::Generator::Swagger::MethodDescription::ApiDecorator < SimpleDelegator
  def normalized_http_method
    @normalized_http_method ||= http_method.downcase
  end

  def summary(method_description:, language:)
    s = Apipie.app.translate(short_description, language)

    if s.blank?
      Apipie::Generator::Swagger::Warning.for_code(
        Apipie::Generator::Swagger::Warning::MISSING_METHOD_SUMMARY_CODE,
        method_description.ruby_name
      ).warn_through_writer

      nil
    else
      s
    end
  end
end
