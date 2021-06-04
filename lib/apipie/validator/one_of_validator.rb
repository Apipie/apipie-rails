module Apipie
  module Validator
    class OneOfValidator < BaseValidator
      include Apipie::DSL::Base
      include Apipie::DSL::Param

      VALIDATOR_TYPE = :one_of

      def self.build(param_description, argument, _options, block)
        return unless argument == VALIDATOR_TYPE && block.is_a?(Proc) && block.arity <= 0

        validator_instance = new(param_description, block)

        # A OneOfValidator with a single param is equivalent to the validator for that param alone,
        # so we return that param's validator directly
        if validator_instance.params_ordered.count == 1
          validator_instance.params_ordered.first.validator
        else
          validator_instance
        end
      end

      def initialize(param_description, block)
        raise ArgumentError, 'A block must be provided' unless block.present? && block.is_a?(Proc)

        super(param_description)

        @proc = block
        @type = :oneOf

        instance_exec(&@proc)
      end

      def validate(value)
        valid_param_for(value).present?
      end

      def process_value(value)
        param = valid_param_for(value)
        return value unless param

        param.process_value(value)
      end

      def description
        'Must match one of the specified validators'
      end

      def params_ordered
        @params_ordered ||= _apipie_dsl_data[:params].map do |args|
          Apipie::ParamDescription.from_dsl_data(param_description.method_description, args)
        end
      end

      def expected_type
        'array'
      end

      def swagger_type
        @type
      end

      private

      def valid_param_for(value)
        error = nil
        result = params_ordered.find do |param|
          begin
            param.validator.validate(value)
          rescue Apipie::ParamError => e
            error = e
            false
          end
        end

        return result unless result.nil?
        raise error unless error.nil?

        nil
      end
    end
  end
end
