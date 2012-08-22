module Apipie

  class ParamMissing < ArgumentError

    attr_accessor :param

    def initialize(param)
      @param = param
    end

    def to_s
      "Missing parameter #{@param}"
    end

  end

end
