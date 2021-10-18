module Apipie
  module Validator
    class BulkValidator < BaseValidator
      include Apipie::DSL::Base
      include Apipie::DSL::Param

      VALIDATOR_TYPE = :bulk

      def initialize(param_description, block)
        raise ArgumentError, 'A block must be provided' unless block.present? && block.is_a?(Proc)

        super(param_description)

        @proc = block
        @type = :bulk

        instance_exec(&@proc)
      end

      def validate(value)
        # always return true for the apipie validator, we use our own validator to do the real param validation
        return true
        end
      end

      def process_value(value)
      end

      def self.build(param_description, argument, options, block)
        return unless argument == VALIDATOR_TYPE && block.is_a?(Proc) && block.arity <= 0
        new(param_description, block)
      end

      def expected_type
        'bulk'
      end

      def description
        'Must be a bulk type for bulk params'
      end
    end
  end
end
