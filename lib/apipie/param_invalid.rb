module Apipie

  class ParamInvalid < ArgumentError

    attr_accessor :param, :value, :error

    def initialize(param, value, error)
      @param = param
      @value = value
      @error = error
    end

    def to_s
      "Invalid parameter #{@param} value #{@value.inspect}: #{@error}"
    end

  end

end
