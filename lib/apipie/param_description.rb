module Apipie

  # method parameter description
  #
  # name - method name (show)
  # desc - description
  # required - boolean if required
  # validator - Validator::BaseValidator subclass
  class ParamDescription

    attr_reader :method_description, :name, :desc, :required, :allow_nil, :validator

    attr_accessor :parent

    def self.from_dsl_data(method_description, args)
      param_name, validator, desc_or_options, options, block = args
      Apipie::ParamDescription.new(method_description,
                                   param_name,
                                   validator,
                                   desc_or_options,
                                   options,
                                   &block)
    end

    def initialize(method_description, name, validator, desc_or_options = nil, options = {}, &block)

      if desc_or_options.is_a?(Hash)
        options = options.merge(desc_or_options)
      elsif desc_or_options.is_a?(String)
        options[:desc] = desc_or_options
      elsif !desc_or_options.nil?
        raise ArgumentError.new("param description: expected description or options as 3rd parameter")
      end

      options.symbolize_keys!

      # we save options to know what was passed in DSL
      @options = options

      @method_description = method_description
      @name = name
      @desc = Apipie.markup_to_html(@options[:desc] || '')
      @parent = @options[:parent]
      @required = if @options.has_key? :required
        @options[:required]
      else
        Apipie.configuration.required_by_default?
      end

      @allow_nil = @options[:allow_nil] || false

      action_awareness

      @validator = nil
      unless validator.nil?
        @validator =
          Validator::BaseValidator.find(self, validator, @options, block)
        raise "Validator not found." unless validator
      end
    end

    def validate(value)
      return true if @allow_nil && value.nil?
      unless @validator.valid?(value)
        error = @validator.error
        error = ParamError.new(error) unless error.is_a? Exception
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

    def merge_with(other_param_desc)
      if self.validator && other_param_desc.validator
        self.validator.merge_with(other_param_desc.validator)
      else
        self.validator ||= other_param_desc.validator
      end
      self
    end

    # merge param descripsiont. Allows defining hash params on more places
    # (e.g. in param_groups). For example:
    #
    #     def_param_group :user do
    #       param :user, Hash do
    #         param :name, String
    #       end
    #     end
    #
    #     param_group :user
    #     param :user, Hash do
    #       param :password, String
    #     end
    def self.unify(params)
      ordering = params.map(&:name)
      params.group_by(&:name).map do |name, param_descs|
        param_descs.reduce(&:merge_with)
      end.sort_by { |param| ordering.index(param.name) }
    end

    # action awareness is being inherited from ancestors (in terms of
    # nested params)
    def action_aware?
      if @options.has_key?(:action_aware)
        return @options[:action_aware]
      elsif @parent
        @parent.action_aware?
      else
        false
      end
    end

    # makes modification that are based on the action that the param
    # is defined for. Typical for required and allow_nil variations in
    # crate/update actions.
    def action_awareness
      if action_aware?
        if !@options.has_key?(:allow_nil)
          if @required
            @allow_nil = false
          else
            @allow_nil = true
          end
        end
        if @method_description.method != "create"
          @required = false
        end
      end
    end

  end

end
