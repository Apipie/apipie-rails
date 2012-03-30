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
      @desc = options[:desc]
      @required = options[:required] || false
      
      @validator = Validator::BaseValidator.find(validator_type, options, block)
      @validator.param_name = @name
      raise "Validator not found." unless validator
    end

    def to_json
      puts "tady #{validator.to_s}"
      {
        :name => name,
        :description => desc,
        :required => required,
        :validator => validator.to_s
      }
    end

  end

end