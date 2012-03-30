module Restapi
  
  module Validator
    
    # to create new validator, inherit from Restapi::Validator::Base
    # and implement class method build and instance method validate
    class BaseValidator

      attr_accessor :param_name

      # find the right validator for given options
      def self.find(argument, options, block)
        self.subclasses.each do |validator_type|
          validator = validator_type.build(argument, options, block)
          return validator if validator
        end
        return nil
      end

      # check if value is valid
      def valid?(value)
        if self.validate(value)
          @error_value = nil
          true
        else
          @error_value = value
          false
        end
      end

      # validator description
      def description
        "TODO: validator description"
      end

      def to_s
        self.description
      end

      def to_json
        self.description
      end

    end

    # validate arguments type
    class TypeValidator < BaseValidator

      def initialize(argument)
        @type = argument
        @type = Integer if @type == Fixnum
      end

      def validate(value)
        return false if value.nil?
        begin
          Kernel.send(@type.to_s, value)
        rescue ArgumentError
          return false
        end
      end

      def self.build(argument, options, block)
        self.new(argument) if argument.is_a?(Class) && argument != Hash
      end

      def error
        "Parameter #{@param_name} expecting to be #{@type.name}, got: #{@error_value.class.name}"
      end

      def description
        "Parameter has to be #{@type}."
      end
    end

    # validate arguments value with regular expression
    class RegexpValidator < BaseValidator

      def initialize(argument)
        @regexp = argument
      end

      def validate(value)
        value =~ @regexp
      end

      def self.build(argument, options, proc)
        self.new(argument) if argument.is_a? Regexp
      end

      def error
        "Parameter #{@param_name} expecting to match /#{@regexp.source}/, got '#{@error_value}'"
      end

      def description
        "Parameter has to match regular expression /#{@regexp.source}/."
      end
    end

    # arguments value must be one of given in array
    class ArrayValidator < BaseValidator

      def initialize(argument)
        @array = argument
      end

      def validate(value)

        @array.find do |expected|
          expected_class = expected.class
          expected_class = Integer if expected_class == Fixnum
          begin
            converted_value = Kernel.send(expected_class.to_s, value)
          rescue ArgumentError
            false
          end
          converted_value === expected
        end
      end

      def self.build(argument, options, proc)
        self.new(argument) if argument.is_a?(Array)
      end

      def error
        "Parameter #{@param_name} has bad value (#{@error_value.inspect}). Expecting one of: #{@array.join(',')}."
      end

      def description
        "Parameter has to be one of: #{@array.join(', ')}."
      end
    end

    class ProcValidator < BaseValidator

      def initialize(argument)
        @proc = argument
      end

      def validate(value)
        (@help = @proc.call(value)) === true
      end

      def self.build(argument, options, proc)
        self.new(argument) if argument.is_a?(Proc) && argument.arity == 1
      end

      def error
        "Parameter #{@param_name} has bad value (\"#{@error_value}\"). #{@help}"
      end

      def description
        ""
      end
    end

    class HashValidator < BaseValidator

      def self.build(argument, options, block)
        self.new(block) if block.is_a?(Proc) && block.arity <= 0 && argument == Hash
      end

      def initialize(argument)
        @proc = argument
        @hash_params = {}

        self.instance_exec(&@proc)
      end
      
      def validate(value)
        if @hash_params
          @hash_params.each do |k, p|
            p.validate(value[k]) if value.has_key?(k) || p.required
          end
        end
        return true
      end

      def error
        "TODO"
      end

      def description
        "TODO"
      end

      def param(param_name, *args, &block)
        @hash_params[param_name.to_sym] = Restapi::ParamDescription.new(param_name, *args, &block)
      end
    end

  end
end