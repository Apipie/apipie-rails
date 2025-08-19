class CustomTypedEnumValidator < Apipie::Validator::EnumValidator
  attr_accessor :expected_type

  def initialize(param_description, enum, type)
    super(param_description, enum)
    self.expected_type = type
  end

  def self.build(param_description, argument, options, block)
    if argument.is_a?(Array) && options.to_h[:type]
      new(param_description, argument, options[:type])
    end
  end
end
