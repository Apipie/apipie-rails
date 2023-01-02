class Apipie::Generator::Swagger::Type
  attr_reader :str_format

  def initialize(type, str_format = nil)
    @type = type
    @str_format = str_format
  end

  def to_s
    @type
  end

  def ==(other)
    other.to_s == self.to_s
  end
end
