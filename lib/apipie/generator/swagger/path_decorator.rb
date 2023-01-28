class Apipie::Generator::Swagger::PathDecorator < SimpleDelegator
  def param_names
    @param_names ||= scan(/:(\w+)/).map { |ar| ar[0].to_sym }
  end

  # @param [Symbol] param_name
  def param?(param_name)
    param_names.include?(param_name)
  end

  # @param [String] controller_method
  #
  # @return [Apipie::Generator::Swagger::PathDecorator]
  def swagger_path(controller_method = nil)
    current_path = gsub(/:(\w+)/, '{\1}').gsub(%r{/$}, '')

    unless current_path.starts_with?('/')
      warn_for_missing_slash(controller_method) if controller_method.present?

      current_path = "/#{current_path}"
    end

    current_path
  end

  private

  # @param [String] controller_method
  def warn_for_missing_slash(controller_method)
    Apipie::Generator::Swagger::Warning.for_code(
      Apipie::Generator::Swagger::Warning::ADDED_MISSING_SLASH_CODE,
      controller_method,
      { path: self }
    ).warn_through_writer
  end
end
