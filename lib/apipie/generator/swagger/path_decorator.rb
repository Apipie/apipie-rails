class Apipie::Generator::Swagger::PathDecorator < SimpleDelegator
  def param_names
    @_param_names ||= self.scan(/:(\w+)/).map { |ar| ar[0].to_sym }
  end

  # @param [Symbol] param_name
  def has_param?(param_name)
    param_names.include?(param_name)
  end
end
