class Apipie::Generator::Swagger::ParamDescription::Name
def initialize(param_description, prefixed_by: nil)
    @param_description = param_description
    @prefixed_by = prefixed_by
  end

  # @return [Hash]
  def to_hash
    name =
      if @prefixed_by.present?
        "#{@prefixed_by}[#{@param_description.name}]"
      else
        @param_description.name
      end

    { name: name }
  end
end
