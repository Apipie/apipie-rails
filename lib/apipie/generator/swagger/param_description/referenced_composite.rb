# A Composite that keeps track when a param description has been added to references
#   and returns the reference instead of the complete object
class Apipie::Generator::Swagger::ParamDescription::ReferencedComposite
  # @param [Apipie::Generator::Swagger::ParamDescription::Composite] composite
  # @param [Symbol, String] param_type
  def initialize(composite, param_type)
    @composite = composite
    @param_type = param_type.to_sym
  end

  def to_swagger
    return ref_to(:name) if added?(:name)

    schema_obj = @composite.to_swagger

    return nil if schema_obj.nil?

    add(schema_obj)

    { '$ref' => ref_to(@param_type) }
  end

  private

  def ref_to(name)
    "#/definitions/#{name}"
  end

  def add(schema)
    Apipie::Generator::Swagger::ReferencedDefinitions.instance.add!(@param_type, schema)
  end

  def added?(name)
    Apipie::Generator::Swagger::ReferencedDefinitions.instance.added?(name)
  end
end
