class Apipie::Generator::Swagger::ParamDescription::In
  IN_KEYWORD_DEFAULT_VALUES = {
    form_data: 'formData',
    query: 'query'
  }.freeze

  def initialize(param_description, in_schema:, default_in_value:, http_method:)
    @param_description = param_description
    @in_schema = in_schema
    @default_in_value = default_in_value
    @http_method = http_method
  end

  # @return [Hash]
  def to_hash
    # The "name" and "in" keys can only be set on root parameters (non-nested)
    return {} if @in_schema

    { in: in_value }
  end

  private

  def in_value
    return @default_in_value if @default_in_value.present?

    if body_allowed_for_current_method?
      IN_KEYWORD_DEFAULT_VALUES[:form_data]
    else
      IN_KEYWORD_DEFAULT_VALUES[:query]
    end
  end

  def body_allowed_for_current_method?
    %w[get head].exclude?(@http_method)
  end
end
