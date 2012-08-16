module Apipie

  # method parameter description
  #
  # name - method name (show)
  # desc - description
  # required - boolean if required
  # validator - Validator::BaseValidator subclass
  class ParamDescription

    attr_reader :name, :desc, :required, :allow_nil, :validator

    attr_accessor :parent

    def initialize(name, *args, &block)

      if args.size > 1 || !args.first.is_a?(Hash)
        validator_type = args.shift || nil
      else
        validator_type = nil
      end
      options = args.pop || {}

      @name = name
      @desc = Apipie.markup_to_html(options[:desc] || '')
      @required = options[:required] || false
      @allow_nil = options[:allow_nil] || false

      @validator = nil
      unless validator_type.nil?
        @validator =
          Validator::BaseValidator.find(self, validator_type, options, block)
        raise "Validator not found." unless validator
      end
    end

    def validate(value)
      return true if @allow_nil && value.nil?
      unless @validator.valid?(value)
        error = @validator.error
        error = ArgumentError.new(error) unless error.is_a? Exception
        raise error
      end
    end

    def full_name
      name_parts = parents_and_self.map(&:name)
      return ([name_parts.first] + name_parts[1..-1].map { |n| "[#{n}]" }).join("")
    end

    # returns an array of all the parents: starting with the root parent
    # ending with itself
    def parents_and_self
      ret = []
      if self.parent
        ret.concat(self.parent.parents_and_self)
      end
      ret << self
      ret
    end

    def to_json
      if validator.is_a? Apipie::Validator::HashValidator
        {
          :name => name.to_s,
          :full_name => full_name,
          :description => desc,
          :required => required,
          :allow_nil => allow_nil,
          :validator => validator.to_s,
          :expected_type => validator.expected_type,
          :params => validator.hash_params_ordered.map(&:to_json)
        }
      else
        {
          :name => name.to_s,
          :full_name => full_name,
          :description => desc,
          :required => required,
          :allow_nil => allow_nil,
          :validator => validator.to_s,
          :expected_type => validator.expected_type
        }
      end
    end

  end

end
