# -*- coding: utf-8 -*-
module Apipie

  module Validator

    # to create new validator, inherit from Apipie::Validator::Base
    # and implement class method build and instance method validate
    class BaseValidator

      attr_accessor :param_description

      def initialize(param_description)
        @param_description = param_description
      end

      def self.inherited(subclass)
        @validators ||= []
        @validators.insert 0, subclass
      end

      # find the right validator for given options
      def self.find(param_description, argument, options, block)
        @validators.each do |validator_type|
          validator = validator_type.build(param_description, argument, options, block)
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

      def param_name
        @param_description.name
      end

      # validator description
      def description
        "TODO: validator description"
      end

      def error
        ParamInvalid.new(param_name, @error_value, description)
      end

      def to_s
        self.description
      end

      def to_json
        self.description
      end

      # what type is expected, mostly string
      # this information is used in cli client
      # thor supported types :string, :hash, :array, :numeric, or :boolean
      def expected_type
        'string'
      end

      def merge_with(other_validator)
        raise NotImplementedError, "Dont know how to merge #{self.inspect} with #{other_validator.inspect}"
      end

    end

    # validate arguments type
    class TypeValidator < BaseValidator

      def initialize(param_description, argument)
        super(param_description)
        @type = argument
      end

      def validate(value)
        return false if value.nil?
        value.is_a? @type
      end

      def self.build(param_description, argument, options, block)
        if argument.is_a?(Class) && (argument != Hash || block.nil?)
          self.new(param_description, argument)
        end
      end

      def description
        "Must be #{@type}"
      end

      def expected_type
        if @type.ancestors.include? Hash
          'hash'
        elsif @type.ancestors.include? Numeric
          'numeric'
        else
          'string'
        end
      end
    end

    # validate arguments value with regular expression
    class RegexpValidator < BaseValidator

      def initialize(param_description, argument)
        super(param_description)
        @regexp = argument
      end

      def validate(value)
        value =~ @regexp
      end

      def self.build(param_description, argument, options, proc)
        self.new(param_description, argument) if argument.is_a? Regexp
      end

      def description
        "Must match regular expression /#{@regexp.source}/."
      end
    end

    # arguments value must be one of given in array
    class ArrayValidator < BaseValidator

      def initialize(param_description, argument)
        super(param_description)
        @array = argument
      end

      def validate(value)
        @array.include?(value)
      end

      def self.build(param_description, argument, options, proc)
        self.new(param_description, argument) if argument.is_a?(Array)
      end

      def description
        "Must be one of: #{@array.join(', ')}."
      end
    end

    class ProcValidator < BaseValidator

      def initialize(param_description, argument)
        super(param_description)
        @proc = argument
      end

      def validate(value)
        (@help = @proc.call(value)) === true
      end

      def self.build(param_description, argument, options, proc)
        self.new(param_description, argument) if argument.is_a?(Proc) && argument.arity == 1
      end

      def error
        ParamInvalid.new(param_name, @error_value, @help)
      end

      def description
        ""
      end
    end

    class HashValidator < BaseValidator
      include Apipie::DSL::Base
      include Apipie::DSL::Param

      def self.build(param_description, argument, options, block)
        self.new(param_description, block, options[:param_group]) if block.is_a?(Proc) && block.arity <= 0 && argument == Hash
      end

      def initialize(param_description, argument, param_group)
        super(param_description)
        @proc = argument
        @param_group = param_group
        self.instance_exec(&@proc)
        # specifying action_aware on Hash influences the child params,
        # not the hash param itself: assuming it's required when
        # updating as well
        if param_description.options[:action_aware] && param_description.options[:required]
          param_description.required = true
        end
        prepare_hash_params
      end

      def hash_params_ordered
        @hash_params_ordered ||= _apipie_dsl_data[:params].map do |args|
          options = args.find { |arg| arg.is_a? Hash }
          options[:parent] = self.param_description
          Apipie::ParamDescription.from_dsl_data(param_description.method_description, args)
        end
      end

      def validate(value)
        if @hash_params
          @hash_params.each do |k, p|
            p.validate(value[k]) if value.has_key?(k) || p.required
          end
        end
        return true
      end

      def description
        "Must be a Hash"
      end

      def expected_type
        'hash'
      end

      # where the group definition should be looked up when no scope
      # given. This is expected to return a controller.
      def _default_param_group_scope
        @param_group && @param_group[:scope]
      end

      def merge_with(other_validator)
        if other_validator.is_a? HashValidator
          @hash_params_ordered = ParamDescription.unify(self.hash_params_ordered + other_validator.hash_params_ordered)
          prepare_hash_params
        else
          super
        end
      end

      def prepare_hash_params
        @hash_params = hash_params_ordered.reduce({}) do |h, param|
          h.update(param.name.to_sym => param)
        end
      end
    end


    # special type of validator: we say that it's not specified
    class UndefValidator < Apipie::Validator::BaseValidator

      def validate(value)
        true
      end

      def self.build(param_description, argument, options, block)
        if argument == :undef
          self.new(param_description)
        end
      end

      def description
        nil
      end
    end

    class NumberValidator < Apipie::Validator::BaseValidator

      def validate(value)
        self.class.validate(value)
      end

      def self.build(param_description, argument, options, block)
        if argument == :number
          self.new(param_description)
        end
      end

      def description
        "Must be a number."
      end

      def self.validate(value)
        value.to_s =~ /\A(0|[1-9]\d*)\Z$/
      end
    end

    class BooleanValidator < Apipie::Validator::BaseValidator

      def validate(value)
        %w[true false].include?(value.to_s)
      end

      def self.build(param_description, argument, options, block)
        if argument == :bool
          self.new(param_description)
        end
      end

      def description
        "Must be 'true' or 'false'"
      end
    end

  end
end

