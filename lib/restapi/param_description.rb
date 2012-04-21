module Restapi

  # method parameter description
  # 
  # name - method name (show)
  # desc - description
  # required - boolean if required
  # validator - Validator::BaseValidator subclass
  class ParamDescription

    attr_reader :name, :desc, :required, :validator
    
    def initialize(name, *args, &block)

      if args.size > 1 || !args.first.is_a?(Hash)
        validator_type = args.shift || nil
      else
        validator_type = nil
      end
      options = args.pop || {}
      
      @name = name
      @desc = Restapi.markup_to_html(options[:desc] || '')
      @required = options[:required] || false
      
      @validator = Validator::BaseValidator.find(validator_type, options, block)
      raise "Validator not found." unless validator
      @validator.param_name = @name
    end

    def validate(value)
      unless @validator.valid?(value)
        raise ArgumentError.new(@validator.error)
      end
    end

    def to_json
      {
        :name => name,
        :description => desc,
        :required => required,
        :validator => validator.to_s
      }
    end

  end

end