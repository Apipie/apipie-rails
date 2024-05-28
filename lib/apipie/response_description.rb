module Apipie

  class ResponseDescription
    class ResponseObject
      include Apipie::DSL::Base
      include Apipie::DSL::Param

      attr_accessor :additional_properties, :typename
      attr_reader :headers

      def initialize(method_description, scope, block, typename)
        @method_description = method_description
        @scope = scope
        @param_group = {scope: scope}
        @additional_properties = false
        @typename = typename
        @headers = []

        self.instance_exec(&block) if block

        prepare_hash_params
      end

      # this routine overrides Param#_default_param_group_scope and is called if Param#param_group is
      # invoked during the instance_exec call in ResponseObject#initialize
      def _default_param_group_scope
        @scope
      end

      def name
        "response #{@code} for #{@method_description.method}"
      end

      def params_ordered
        @params_ordered ||= _apipie_dsl_data[:params].map do |args|
          options = args.find { |arg| arg.is_a? Hash }
          options[:param_group] = @param_group
          Apipie::ParamDescription.from_dsl_data(@method_description, args) unless options[:only_in] == :request
        end.compact
      end

      def prepare_hash_params
        @hash_params = params_ordered.reduce({}) do |h, param|
          h.update(param.name.to_sym => param)
        end
      end

      # @param [String] header_name
      # @param [String, symbol, Class] validator
      # @param [String] description
      # @param [Hash] options
      def header(header_name, validator, description, options = {})
        @headers << {
          name: header_name,
          validator: validator.to_s.downcase,
          description: description,
          options: options
        }
      end
    end
  end


  class ResponseDescription
    include Apipie::DSL::Base
    include Apipie::DSL::Param

    attr_reader :code, :description, :scope, :type_ref, :hash_validator, :is_array_of

    def self.from_dsl_data(method_description, code, args)
      options, scope, block, adapter = args

      Apipie::ResponseDescription.new(method_description,
                                      code,
                                      options,
                                      scope,
                                      block,
                                      adapter)
    end

    def initialize(method_description, code, options, scope, block, adapter)

      @type_ref = options[:param_group]
      @is_array_of = options[:array_of] || false
      raise ReturnsMultipleDefinitionError, options if @is_array_of && @type_ref

      @type_ref ||= @is_array_of

      @method_description = method_description

      if code.is_a? Symbol
        @code = Rack::Utils::SYMBOL_TO_STATUS_CODE[code]
      else
        @code = code
      end

      @description = options[:desc]
      if @description.nil?
        @description = Rack::Utils::HTTP_STATUS_CODES[@code]
        raise "Cannot infer description from status code #{@code}" if @description.nil?
      end
      @scope = scope

      if adapter
        @response_object = adapter
      else
        @response_object = ResponseObject.new(method_description, scope, block, @type_ref)
      end

      @response_object.additional_properties ||= options[:additional_properties]
    end

    def is_array?
      @is_array_of != false
    end

    def typename
      @response_object.typename
    end

    def param_description
      nil
    end

    def params_ordered
      @response_object.params_ordered
    end

    def additional_properties
      !!@response_object.additional_properties
    end
    alias allow_additional_properties additional_properties

    # @return [Array<Hash>]
    def headers
      # TODO: Support headers for Apipie::ResponseDescriptionAdapter
      if @response_object.is_a?(Apipie::ResponseDescriptionAdapter)
        return []
      end

      @response_object.headers
    end

    # @return [Hash{Symbol->TrueClass | FalseClass}]
    def to_json(lang = nil)
      {
          :code => code,
          :description => Apipie.app.translate(description, lang),
          :is_array => is_array?,
          :returns_object => params_ordered.map{ |param| param.to_json(lang).tap{|h| h.delete(:validations) }}.flatten,
          :additional_properties => additional_properties,
          :headers => headers
      }
    end
  end
end
