module Apipie

  # method parameter description
  #
  # name - method name (show)
  # desc - description
  # required - boolean if required
  # validator - Validator::BaseValidator subclass
  class ParamDescription

    attr_reader :method_description, :name, :desc, :allow_nil, :allow_blank, :validator, :options, :metadata, :show, :as, :validations, :response_only, :request_only
    attr_reader :additional_properties, :is_array
    attr_accessor :parent, :required

    alias_method :response_only?, :response_only
    alias_method :request_only?, :request_only
    alias_method :is_array?, :is_array

    def self.from_dsl_data(method_description, args)
      param_name, validator, desc_or_options, options, block = args
      Apipie::ParamDescription.new(method_description,
                                   param_name,
                                   validator,
                                   desc_or_options,
                                   options,
                                   &block)
    end

    def to_s
      "ParamDescription: #{method_description.id}##{name}"
    end

    def ==(other)
      return false unless self.class == other.class
      if method_description == other.method_description && @options == other.options
        true
      else
        false
      end
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
      if @options[:param_group]
        @from_concern = @options[:param_group][:from_concern]
      end

      @method_description = method_description
      @name = concern_subst(name)
      @as = options[:as] || @name
      @desc = preformat_text(@options[:desc])

      @parent = @options[:parent]
      @metadata = @options[:meta]

      @required = is_required?

      @response_only = (@options[:only_in] == :response)
      @request_only = (@options[:only_in] == :request)
      raise ArgumentError.new("'#{@options[:only_in]}' is not a valid value for :only_in") if (!@response_only && !@request_only) && @options[:only_in].present?

      @show = if @options.has_key? :show
        @options[:show]
      else
        true
      end

      @allow_nil = @options[:allow_nil] || false
      @allow_blank = @options[:allow_blank] || false

      action_awareness

      if validator
        if (validator != Hash) && (validator.is_a? Hash) && (validator[:array_of])
          @is_array = true
          rest_of_options = validator
          validator = validator[:array_of]
          options.merge!(rest_of_options.select{|k,v| k != :array_of })
          raise "an ':array_of =>' validator is allowed exclusively on response-only fields" unless @response_only
        end
        @validator = Validator::BaseValidator.find(self, validator, @options, block)
        raise "Proc validators not supported on param #{method_description.id}:#{name}" if (@validator.is_a? Validator::ProcValidator) && @response_only
        raise "Validator for #{validator} not found." unless @validator
      end

      @validations = Array(options[:validations]).map {|v| concern_subst(Apipie.markup_to_html(v)) }

      @additional_properties = @options[:additional_properties]
    end

    def from_concern?
      method_description.from_concern? || @from_concern
    end

    def normalized_value(value)
      if value.is_a?(ActionController::Parameters) && !value.is_a?(Hash)
        value.to_unsafe_hash
      elsif value.is_a? Array
        value.map { |v| normalized_value (v) }
      else
        value
      end
    end

    def validate(value)
      return true if @allow_nil && value.nil?
      return true if @allow_blank && value.blank?
      value = normalized_value(value)
      if (!@allow_nil && value.nil?) || !@validator.valid?(value)
        error = @validator.error
        error = ParamError.new(error) unless error.is_a? StandardError
        raise error
      end
    end

    def process_value(value)
      value = normalized_value(value)
      if @validator.respond_to?(:process_value)
        @validator.process_value(value)
      else
        value
      end
    end

    def full_name
      name_parts = full_path
      return name.to_s if name_parts.length <= 1
      return ([name_parts.first] + name_parts[1..-1].map { |n| "[#{n}]" }).join("")
    end

    def full_path
      path = parents_and_self.map { |p| p.name if p.show }.compact
      return [name.to_s] if path.blank?
      return path
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

    def to_json(lang = nil)
      hash = { :name => name.to_s,
               :full_name => full_name,
               :description => preformat_text(Apipie.app.translate(@options[:desc], lang)),
               :required => required,
               :allow_nil => allow_nil,
               :allow_blank => allow_blank,
               :validator => validator.to_s,
               :expected_type => validator.expected_type,
               :metadata => metadata,
               :show => show,
               :validations => validations }
      if sub_params = validator.params_ordered
        hash[:params] = sub_params.map { |p| p.to_json(lang)}
      end
      hash
    end

    def merge_with(other_param_desc)
      if self.validator && other_param_desc.validator
        self.validator.merge_with(other_param_desc.validator)
      else
        self.validator ||= other_param_desc.validator
      end
      self
    end

    # merge param descriptions. Allows defining hash params on more places
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

    def self.merge(target_params, source_params)
      params_to_merge, params_to_add = source_params.partition do |source_param|
        target_params.any? { |target_param| source_param.name == target_param.name }
      end
      unify(target_params + params_to_merge)
      target_params.concat(params_to_add)
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

    def as_action
      if @options[:param_group] && @options[:param_group][:options] &&
          @options[:param_group][:options][:as]
        @options[:param_group][:options][:as].to_s
      elsif @parent
        @parent.as_action
      else
        @method_description.method
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
        if as_action != "create"
          @required = false
        end
      end
    end

    def concern_subst(string)
      return string if string.nil? or !from_concern?

      original = string
      string = ":#{original}" if original.is_a? Symbol

      replaced = method_description.resource.controller._apipie_perform_concern_subst(string)

      return original if replaced == string
      return replaced.to_sym if original.is_a? Symbol
      return replaced
    end

    def preformat_text(text)
      concern_subst(Apipie.markup_to_html(text || ''))
    end

    def is_required?
      if @options.has_key?(:required)
        if (@options[:required] == true) || (@options[:required] == false)
          @options[:required]
        else
          Array(@options[:required]).include?(@method_description.method.to_sym)
        end
      else
        Apipie.configuration.required_by_default?
      end
    end

  end

end
