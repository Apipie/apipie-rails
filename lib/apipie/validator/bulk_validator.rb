module Apipie
  module Validator
    class BulkValidator < BaseValidator
      include Apipie::DSL::Base
      include Apipie::DSL::Param

      ITEMS_OPTIONS_EXCLUDE = %i[of array_of desc].freeze
      VALIDATOR_TYPE = :bulk

      # def initialize(param_description, block)
      #   raise ArgumentError, 'A block must be provided' unless block.present? && block.is_a?(Proc)

      #   super(param_description)

      #   @proc = block
      #   @type = :bulk

      #   instance_exec(&@proc)
      # end

      def initialize(param_description, items_argument, options = {}, block)
        super(param_description)

        items_param_description = Apipie::ParamDescription.new(
          param_description.method_description,
          param_description.name,
          items_argument,
          nil,
          options.reject { |k, _| ITEMS_OPTIONS_EXCLUDE.include?(k) },
          true,
          &block
        )
        @validator = items_param_description.validator
        @type = :bulk
      end

      def params_ordered
        # @params_ordered ||= _apipie_dsl_data[:params].map do |args|
        #   options = args.find { |arg| arg.is_a? Hash }
        #   options[:parent] = param_description
        #   Apipie::ParamDescription.from_dsl_data(param_description.method_description, args, always_valid: true)
        # end
        @validator.params_ordered
      end

      def validate(_value)
        # always return true for the apipie validator, we use our own validator to do the real param validation
        true
      end

      # def self.build(param_description, argument, _options, block)
      #   return unless argument == VALIDATOR_TYPE && block.is_a?(Proc) && block.arity <= 0

      #   new(param_description, block)
      # end

      def self.build(param_description, argument, options, block)
        return unless argument == VALIDATOR_TYPE && block.is_a?(Proc) && block.arity <= 0

        items_argument = options.fetch(:of, Hash)
        new(param_description, items_argument, options, block)
      end

      def expected_type
        'bulk'
      end

      def description
        'bulk must be an Array of Hash'
      end

      def items_validator
        @validator
      end
    end
  end
end
