class Apipie::Generator::Swagger::ParamDescription::Description
  def initialize(param_description, language:)
    @param_description = param_description
    @language = language
  end

  # @return [Hash]
  def to_hash
    description = @param_description.options[:desc]

    return {} if description.blank?

    { description: Apipie.app.translate(description, @language) }
  end
end
