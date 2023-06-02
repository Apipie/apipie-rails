class Apipie::Generator::Swagger::ReferencedDefinitions
  include Singleton

  attr_reader :definitions

  def initialize
    @definitions = {}
  end

  def add!(param_type, schema)
    @definitions[param_type] = schema
  end

  def added?(name)
    @definitions.key?(name)
  end
end
