module Apipie
  module Validator
    class NestedHashValidator < BaseValidator
      ITEMS_OPTIONS_EXCLUDE = %i[of desc].freeze

      def initialize(param_description, values_argument, options = {}, block = nil)
        super(param_description)

        values_param_description = Apipie::ParamDescription.new(
          param_description.method_description,
          param_description.name,
          values_argument,
          nil,
          options.reject { |k, _| ITEMS_OPTIONS_EXCLUDE.include?(k) },
          &block
        )
        @validator = values_param_description.validator
        @type = Hash
      end

      def validate(value)
        value ||= {}
        return false if value.class != Hash

        value.values.all? do |child|
          @validator.validate(child)
        end
      end

      def process_value(value)
        value ||= {}
        value.transform_values do |value|
          @validator.process_value(value)
        end
      end

      def self.build(param_description, argument, options, block)
        # in Ruby 1.8.x the arity on block without args is -1
        # while in Ruby 1.9+ it is 0
        return unless argument == Hash && options[:of].present?

        values_argument = options.fetch(:of, String)

        new(param_description, values_argument, options, block)
      end

      def expected_type
        'hash'
      end

      def description
        'Must be a Hash of nested elements'
      end

      def params_ordered
        @validator.params_ordered
      end

      def values_validator
        @validator
      end
    end
  end
end
