class CustomBoolValidator < Apipie::Validator::BaseValidator
  def validate(value)
    value.in?([true, false])
  end

  def self.build(param_description, argument, options, block)
    new(param_description) if argument == :custom_bool
  end

  def description
    "Must be a boolean."
  end

  def ignore_allow_blank?
    true
  end
end
