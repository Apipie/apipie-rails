module Apipie

  def self.prop(name, expected_type, options={}, sub_properties=[])
    Apipie::ResponseDescriptionAdapter::PropDesc.new(name, expected_type, options, sub_properties)
  end

  def self.additional_properties(yesno)
    Apipie::ResponseDescriptionAdapter::AdditionalPropertiesModifier.new(yesno)
  end

  class ResponseDescriptionAdapter
    class Modifier
      def apply(adapter)
        raise "Modifer subclass must implement 'apply' method"
      end
    end

    class AdditionalPropertiesModifier < Modifier
      def initialize(additional_properties_allowed)
        @additional_properties_allowed = additional_properties_allowed
      end

      def apply(adapter)
        adapter.additional_properties =  @additional_properties_allowed
      end
    end
  end


  class ResponseDescriptionAdapter

    #
    # A ResponseDescriptionAdapter::PropDesc object pretends to be an Apipie::Param in a ResponseDescription
    #
    # To successfully masquerade as such, it needs to:
    #    respond_to?('name') and/or ['name'] returning the name of the parameter
    #    respond_to?('required') and/or ['required'] returning boolean
    #    respond_to?('additional_properties') and/or ['additional_properties'] returning boolean
    #    respond_to?('validator') and/or ['validator'] returning 'nil' (so type is 'string'), or an object that:
    #           1) describes a type.  currently type is inferred as follows:
    #                 if validator.is_a? Apipie::Validator::EnumValidator -->  respond_to? 'values' (returns array).  Type is enum or boolean
    #                 else: use v.expected_type().  This is expected to be the swagger type, or:
    #                     numeric ==> swagger type is 'number'
    #                     hash ==> swagger type is 'object' and validator should respond_to? 'params_ordered'
    #                     array ==> swagger type is array and validator (FUTURE) should indicate type of element

    class PropDesc

      def to_s
        "PropDesc -- name: #{@name}  type: #{@expected_type} required: #{@required} options: #{@options} subprop count: #{@sub_properties.length} additional properties: #{@additional_properties}"
      end

      #
      # a ResponseDescriptionAdapter::PropDesc::Validator pretends to be an Apipie::Validator
      #
      class Validator
        attr_reader :expected_type

        def [](key)
          return self.send(key) if self.respond_to?(key.to_s)
        end

        def initialize(expected_type, enum_values=nil, sub_properties=nil)
          @expected_type = expected_type
          @enum_values = enum_values
          @is_enum = !!enum_values
          @sub_properties = sub_properties
        end

        def is_enum?
          !!@is_enum
        end

        def values
          @enum_values
        end

        def params_ordered
          raise "Only validators with expected_type 'object' can have sub-properties" unless @expected_type == 'object'
          @sub_properties
        end
      end

      #======================================================================


      def initialize(name, expected_type, options={}, sub_properties=[])
        @name = name
        @required = true
        @required = false if options[:required] == false
        @expected_type = expected_type
        @additional_properties = false

        options[:desc] ||= options[:description]
        @description = options[:desc]
        @options = options
        @is_array = options[:is_array] || false
        @sub_properties = []
        for prop in sub_properties do
          add_sub_property(prop)
        end
      end

      def [](key)
        return self.send(key) if self.respond_to?(key.to_s)
      end

      def add_sub_property(prop_desc)
        raise "Only properties with expected_type 'object' can have sub-properties" unless @expected_type == 'object'
        if prop_desc.is_a? PropDesc
          @sub_properties << prop_desc
        elsif prop_desc.is_a? Modifier
          prop_desc.apply(self)
        else
          raise "Unrecognized prop_desc type (#{prop_desc.class})"
        end
      end

      def to_json(lang)
        {
            name: name,
            required: required,
            validator: validator,
            description: description,
            additional_properties: additional_properties,
            is_array: is_array?,
            options: options
        }
      end
      attr_reader :name, :required, :expected_type, :options, :description
      attr_accessor :additional_properties

      alias_method :desc, :description

      def is_array?
        @is_array
      end

      def validator
        Validator.new(@expected_type, options[:values], @sub_properties)
      end
    end
  end

  #======================================================================

  class ResponseDescriptionAdapter

    def self.from_self_describing_class(cls)
      adapter = ResponseDescriptionAdapter.new(cls.to_s)
      props = cls.describe_own_properties
      adapter.add_property_descriptions(props)
      adapter
    end

    def initialize(typename)
      @property_descs = []
      @additional_properties = false
      @typename = typename
    end

    attr_accessor :additional_properties, :typename

    def allow_additional_properties
      additional_properties
    end

    def to_json
      params_ordered.to_json
    end

    def add(prop_desc)
      if prop_desc.is_a? PropDesc
        @property_descs << prop_desc
      elsif prop_desc.is_a? Modifier
        prop_desc.apply(self)
      else
        raise "Unrecognized prop_desc type (#{prop_desc.class})"
      end
    end

    def add_property_descriptions(prop_descs)
      for prop_desc in prop_descs
        add(prop_desc)
      end
    end

    def property(name, expected_type, options)
      @property_descs << PropDesc.new(name, expected_type, options)
    end

    def params_ordered
      @property_descs
    end

    def is_array?
      false
    end
  end
end
