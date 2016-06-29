module Apipie

  class Error < StandardError
  end

  class ParamError < Error
  end

  class UnknownCode < Error
  end

  # abstract
  class DefinedParamError < ParamError
    attr_accessor :param

    def initialize(param)
      @param = param
    end
  end

  class ParamMissing < DefinedParamError
    def to_s
      unless @param.options[:missing_message].nil?
        if @param.options[:missing_message].kind_of?(Proc)
          @param.options[:missing_message].call
        else
          @param.options[:missing_message].to_s
        end
      else
        "Missing parameter #{@param.name}"
      end
    end
  end

  class UnknownParam < DefinedParamError
    def to_s
      "Unknown parameter #{@param}"
    end
  end

  class ParamInvalid < DefinedParamError
    attr_accessor :value, :error

    def initialize(param, value, error)
      super param
      @value = value
      @error = error
    end

    def to_s
      "Invalid parameter '#{@param}' value #{@value.inspect}: #{@error}"
    end
  end

end
