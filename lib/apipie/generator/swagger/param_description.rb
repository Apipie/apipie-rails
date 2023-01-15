module Apipie::Generator::Swagger::ParamDescription
  # @param [Apipie::MethodDescription] method_description
  # @param [String] name
  #
  # @return [Apipie::ParamDescription]
  def self.create_for_missing_param(method_description, name)
    Apipie::ParamDescription.new(
      method_description,
      name,
      Numeric,
      {
        in: "path",
        required: true,
        added_from_path: true,
      }
    )
  end
end
