module Apipie
  module Validator
    # to create new validator, inherit from Apipie::Validator::Base
    # and implement class method build and instance method validate
    class BaseValidator
      attr_accessor :param_description

      def initialize(param_description)
        @param_description = param_description
      end

      def inspected_fields
        [:param_description]
      end

      def inspect
        string = "#<#{self.class.name}:#{self.object_id} "
        fields = inspected_fields.map {|field| "#{field}: #{self.send(field)}"}
        string << fields.join(", ") << ">"
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

      def format_description_value(value)
        "<code>#{CGI::escapeHTML(value.to_s)}</code>"
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

      def swagger_type
        expected_type
      end

      def merge_with(other_validator)
        return self if self == other_validator
        raise NotImplementedError, "Don't know how to merge #{self.inspect} with #{other_validator.inspect}"
      end

      def params_ordered
        nil
      end

      def ==(other)
        return false unless self.class == other.class
        if param_description == other.param_description
          true
        else
          false
        end
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
        "Must be a #{@type}"
      end

      def expected_type
        if @type.ancestors.include? Hash
          'hash'
        elsif @type.ancestors.include? Array
          'array'
        elsif @type.ancestors.include? Numeric
          'numeric'
        elsif @type.ancestors.include? File
          'file'
        else
          'string'
        end
      end

      def swagger_type
        # We override expected_type here so that Integer fields
        # are properly typed in the OpenAPI generator
        if @type.ancestors.include? Integer
          'long'
        else
          expected_type
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
        "Must match regular expression #{format_description_value("/#{@regexp.source}/")}."
      end
    end

    # arguments value must be one of given in array
    class EnumValidator < BaseValidator
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

      def values
        @array
      end

      def description
        string = @array.map { |value| format_description_value(value) }.join(', ')
        "Must be one of: #{string}."
      end
    end

    # arguments value must be an array
    class ArrayValidator < Apipie::Validator::BaseValidator
      ITEMS_OPTIONS_EXCLUDE = %i[of array_of desc].freeze

      attr_reader :items_validator

      def initialize(param_description, argument, options = {})
        super(param_description)
        @type = argument
        @items_type = options[:of]
        @items_enum = options[:in]

        items_param_description = Apipie::ParamDescription.new(
          param_description.method_description,
          param_description.name,
          @items_type,
          nil,
          options.reject { |k, _| ITEMS_OPTIONS_EXCLUDE.include?(k) }
        )
        @items_validator = items_param_description.validator
      end

      def validate(values)
        return false unless process_value(values).respond_to?(:each) && !process_value(values).is_a?(String)

        process_value(values).all? { |v| validate_item(v)}
      end

      def process_value(values)
        values || []
      end

      def description
        "Must be an array of #{items}"
      end

      def expected_type
        'array'
      end

      def self.build(param_description, argument, options, block)
        return unless argument == Array && !block.is_a?(Proc)

        new(param_description, argument, options)
      end

      private

      def enum
        if @items_enum.kind_of?(Proc)
          @items_enum = Array(@items_enum.call)
        end
        @items_enum
      end

      def validate_item(value)
        has_valid_type?(value) &&
          is_valid_value?(value)
      end

      def has_valid_type?(value)
        if @items_type
          if @items_validator.is_a?(BaseValidator)
            @items_validator.valid?(value)
          else
            value.is_a?(@items_type)
          end
        else
          true
        end
      end

      def is_valid_value?(value)
        if enum
          enum.include?(value)
        else
          true
        end
      end

      def items
        unless enum
          @items_type || "any type"
        else
          enum.inspect
        end
      end
    end

    class ArrayClassValidator < BaseValidator

      def initialize(param_description, argument)
        super(param_description)
        @array = argument
      end

      def validate(value)
        @array.include?(value.class)
      end

      def self.build(param_description, argument, options, block)
        if argument.is_a?(Array) && argument.first.class == Class && !block.is_a?(Proc)
          self.new(param_description, argument)
        end
      end

      def description
        string = @array.map { |value| format_description_value(value) }.join(', ')
        "Must be one of: #{string}."
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
        self.new(param_description, block, options[:param_group]) if block.is_a?(Proc) && block.arity <= 0 && argument == Hash && options[:of].blank?
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

      def params_ordered
        @params_ordered ||= _apipie_dsl_data[:params].map do |args|
          options = args.find { |arg| arg.is_a? Hash }
          options[:parent] = self.param_description
          Apipie::ParamDescription.from_dsl_data(param_description.method_description, args)
        end
      end

      def validate(value)
        return false if !value.is_a? Hash
        if @hash_params
          @hash_params.each do |k, p|
            if Apipie.configuration.validate_presence?
              raise ParamMissing.new(p) if p.required && !value.has_key?(k)
            end
            if Apipie.configuration.validate_value?
              p.validate(value[k]) if value.has_key?(k)
            end
          end
        end
        return true
      end

      def process_value(value)
        if @hash_params && value
          return @hash_params.each_with_object({}) do |(key, param), api_params|
            if value.has_key?(key)
              api_params[param.as] = param.process_value(value[key])
            end
          end
        end
      end

      def description
        'Must be a Hash'
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
          @params_ordered = ParamDescription.unify(self.params_ordered + other_validator.params_ordered)
          prepare_hash_params
        else
          super
        end
      end

      def prepare_hash_params
        @hash_params = params_ordered.reduce({}) do |h, param|
          h.update(param.name.to_sym => param)
        end
      end
    end


    # special type of validator: we say that it's not specified
    class UndefValidator < BaseValidator
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

    class DecimalValidator < BaseValidator
      def validate(value)
        self.class.validate(value)
      end

      def self.build(param_description, argument, options, block)
        return unless argument == :decimal

        new(param_description)
      end

      def description
        'Must be a decimal number.'
      end

      def expected_type
        'numeric'
      end

      def self.validate(value)
        value.to_s =~ /\A^[-+]?[0-9]+([,.][0-9]+)?\Z$/
      end
    end

    class NumberValidator < BaseValidator
      def validate(value)
        self.class.validate(value)
      end

      def self.build(param_description, argument, options, block)
        return unless argument == :number

        new(param_description)
      end

      def description
        'Must be a number.'
      end

      def expected_type
        'numeric'
      end

      def self.validate(value)
        value.to_s =~ /\A(0|[1-9]\d*)\Z$/
      end
    end

    class BooleanValidator < BaseValidator
      def validate(value)
        %w[true false 1 0].include?(value.to_s)
      end

      def self.build(param_description, argument, _options, _block)
        return unless %i[bool boolean].include?(argument)

        new(param_description)
      end

      def expected_type
        'boolean'
      end

      def description
        string = %w[true false 1 0].map { |value| format_description_value(value) }.join(', ')
        "Must be one of: #{string}."
      end
    end

    class NestedValidator < BaseValidator
      ITEMS_OPTIONS_EXCLUDE = %i[of array_of desc].freeze

      def initialize(param_description, items_argument, options, block)
        super(param_description)

        items_param_description = Apipie::ParamDescription.new(
          param_description.method_description,
          param_description.name,
          items_argument,
          nil,
          options.reject { |k, _| ITEMS_OPTIONS_EXCLUDE.include?(k) },
          &block
        )
        @validator = items_param_description.validator
        @type = Array
      end

      def validate(value)
        value ||= [] # Rails convert empty array to nil
        return false if value.class != Array

        value.all? do |child|
          @validator.validate(child)
        end
      end

      def process_value(value)
        value ||= [] # Rails convert empty array to nil
        value.map do |child|
          @validator.process_value(child)
        end
      end

      def self.build(param_description, argument, options, block)
        # in Ruby 1.8.x the arity on block without args is -1
        # while in Ruby 1.9+ it is 0
        return unless argument == Array && block.is_a?(Proc) && block.arity <= 0

        items_argument = options.fetch(:of, Hash)

        new(param_description, items_argument, options, block)
      end

      def expected_type
        'array'
      end

      def description
        'Must be an Array of nested elements'
      end

      def params_ordered
        @validator.params_ordered
      end

      def items_validator
        @validator
      end
    end
  end
end
