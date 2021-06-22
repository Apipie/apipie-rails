module Apipie
  class SwaggerGenerator
    require 'json'
    require 'ostruct'
    require 'open3'
    require 'zlib' if Apipie.configuration.swagger_generate_x_computed_id_field?

    attr_reader :computed_interface_id

    def initialize(apipie)
      @apipie = apipie
      @issued_warnings = []
    end

    def json_body?
      Apipie.configuration.swagger_content_type_input == :json
    end

    def params_in_body_use_reference?
      Apipie.configuration.swagger_json_input_uses_refs
    end

    def responses_use_reference?
      Apipie.configuration.swagger_responses_use_refs?
    end

    def include_warning_tags?
      Apipie.configuration.swagger_include_warning_tags
    end

    def generate_from_resources(version, resources, method_name, lang, clear_warnings = false)
      init_swagger_vars(version, lang, clear_warnings)

      @lang = lang
      @only_method = method_name
      # The resources hash is sorted to ensure output order is not dependent on module load order which could
      # vary between environments.
      add_resources(resources.sort.to_h)

      if Apipie.configuration.swagger_generate_x_computed_id_field?
        @openapi_schema[:info]['x-computed-id'] = @computed_interface_id
      end
      @openapi_schema
    end

    #--------------------------------------------------------------------------
    # Initialization
    #--------------------------------------------------------------------------

    def init_swagger_vars(version, lang, clear_warnings = false)
      # docs = {
      #     :name => Apipie.configuration.app_name,
      #     :info => Apipie.app_info(version, lang),
      #     :copyright => Apipie.configuration.copyright,
      #     :doc_url => Apipie.full_url(url_args),
      #     :api_url => Apipie.api_base_url(version),
      #     :resources => _resources
      # }

      @openapi_schema = {
        openapi: '3.0.3',
        info: {
          title: "#{Apipie.configuration.app_name} (params in:#{json_body? ? 'body' : 'formData'})",
          description: "#{Apipie.app_info(version, lang)}#{Apipie.configuration.copyright}",
          version: version.to_s,
          'x-copyright': Apipie.configuration.copyright
        },
        servers: [
          {
            url: if Apipie.configuration.swagger_api_host
                   Apipie.configuration.swagger_api_host + Apipie.api_base_url(version)
                 else
                   Apipie.api_base_url(version)
                 end
          }
        ],
        paths: {},
        components: {
          schemas: {}
        },
        tags: []
      }

      @paths = @openapi_schema[:paths]
      @tags = @openapi_schema[:tags]
      @schemas = @openapi_schema[:components][:schemas]

      @issued_warnings = [] if clear_warnings || @issued_warnings.nil?
      @computed_interface_id = 0

      @current_lang = lang
    end

    #--------------------------------------------------------------------------
    # Engine interface methods
    #--------------------------------------------------------------------------

    def add_resources(resources)
      resources.each do |resource_name, resource_defs|
        next unless resource_defs._show

        add_resource_description(resource_name, resource_defs)
        add_resource_methods(resource_name, resource_defs)
      end
    end

    def add_resource_methods(_, resource_defs)
      resource_defs._methods.each do |_, apipie_method_defs|
        add_ruby_method(@paths, apipie_method_defs)
      end
    end

    #--------------------------------------------------------------------------
    # Logging, debugging and regression-testing utilities
    #--------------------------------------------------------------------------

    def ruby_name_for_method(method)
      return '<no method>' if method.nil?

      method.resource.controller.name + '#' + method.method
    end

    def warn_missing_method_summary() warn 100, 'missing short description for method'; end

    def warn_added_missing_slash(path) warn 101, "added missing / at beginning of path: #{path}"; end

    def warn_no_return_codes_specified() warn 102, "no return codes ('errors') specified"; end

    def warn_hash_without_internal_typespec(param_name) warn 103, "the parameter :#{param_name} is a generic Hash without an internal type specification"; end

    def warn_optional_param_in_path(param_name) warn 104, "the parameter :#{param_name} is 'in-path'.  Ignoring 'not required' in DSL"; end

    def warn_optional_without_default_value(param_name) warn 105, "the parameter :#{param_name} is optional but default value is not specified (use :default_value => ...)"; end

    def warn_param_ignored_in_form_data(param_name) warn 106, "ignoring param :#{param_name} -- cannot include Hash without fields in a formData specification"; end

    def warn_path_parameter_not_described(name, path) warn 107, "the parameter :#{name} appears in the path #{path} but is not described"; end

    def warn_inferring_boolean(name) warn 108, "the parameter [#{name}] is Enum with [true,false] values. Inferring 'boolean'"; end

    def warn(warning_num, msg)
      suppress = Apipie.configuration.swagger_suppress_warnings
      return if suppress == true
      return if suppress.is_a?(Array) && suppress.include?(warning_num)

      method_id = ruby_name_for_method(@current_method)
      warning_id = "#{method_id}#{warning_num}#{msg}"

      if @issued_warnings.include?(warning_id)
        # Already issued this warning for the current method
        return
      end

      print "WARNING (#{warning_num}): [#{method_id}] -- #{msg}\n"
      @issued_warnings.push(warning_id)
      @warnings_issued = true
    end

    def info(msg)
      print "--- INFO: [#{ruby_name_for_method(@current_method)}] -- #{msg}\n"
    end

    # the @computed_interface_id is a number that is uniquely derived from the list of operations
    # added to the swagger definition (in an order-dependent way).
    # it can be used for regression testing, allowing some differentiation between changes that
    # result from changes to the input and those that result from changes to the generation
    # algorithms.
    # note that at the moment, this only takes operation ids into account, and ignores parameter
    # definitions, so it's only partially useful.
    def include_op_id_in_computed_interface_id(op_id)
      if Apipie.configuration.swagger_generate_x_computed_id_field?
        @computed_interface_id = Zlib::crc32("#{@computed_interface_id} #{op_id}")
      end
    end

    #--------------------------------------------------------------------------
    # Create a tag description for a described resource
    #--------------------------------------------------------------------------

    def tag_name_for_resource(resource)
      # resource.controller
      resource._id
    end

    def add_resource_description(_, resource)
      return unless resource._full_description

      @tags << {
        name: tag_name_for_resource(resource),
        description: Apipie.app.translate(resource._full_description, @current_lang)
      }
    end

    #--------------------------------------------------------------------------
    # Create swagger definitions for a ruby method
    #--------------------------------------------------------------------------

    def add_ruby_method(paths, ruby_method)
      if @only_method
        return unless ruby_method.method == @only_method
      else
        return unless ruby_method.show
      end

      ruby_method.apis.each do |api|
        # controller: ruby_method.resource.controller.name,

        path = swagger_path(api.path)
        paths[path] ||= {}
        methods = paths[path]
        @current_method = ruby_method

        @warnings_issued = false
        responses = swagger_responses_hash_for_method(ruby_method)
        warning_tags = if include_warning_tags? && @warnings_issued
                         ['warnings issued']
                       else
                         []
                       end

        op_id = swagger_op_id_for_path(api.http_method, api.path)

        include_op_id_in_computed_interface_id(op_id)

        method_key = api.http_method.downcase
        @current_http_method = method_key

        methods[method_key] = {
          tags: [tag_name_for_resource(ruby_method.resource)] + warning_tags + ruby_method.tag_list.tags,
          operationId: op_id,
          summary: Apipie.app.translate(api.short_description, @current_lang),
          parameters: swagger_params_array_for_method(ruby_method, api.path),
          responses: responses,
          description: ruby_method.full_description
        }.tap do |method|
          request_body = swagger_request_body_for_method(ruby_method, api.path)
          unless request_body.nil?
            method[:requestBody] = request_body
            # This preserves the Swagger Codegen behaviour of naming the body parameter "body" instead of generating a name based on the model.
            # See https://github.com/OpenAPITools/openapi-generator/blob/master/docs/migration-from-swagger-codegen.md#body-parameter-name
            method['x-codegen-request-body-name'] = 'body'
          end
        end

        if methods[method_key][:summary].nil?
          methods[method_key].delete(:summary)
          warn_missing_method_summary
        end
      end
    end

    #--------------------------------------------------------------------------
    # Utilities for conversion of ruby syntax to swagger syntax
    #--------------------------------------------------------------------------

    def swagger_path(str)
      str = str.gsub(/:(\w+)/, '{\1}')
      str = str.gsub(/\/$/, '')

      if str[0] != '/'
        warn_added_missing_slash(str)
        str = '/' + str
      end
      str
    end

    def remove_colons(str)
      str.gsub(':', '_')
    end

    def swagger_op_id_for_method(method)
      remove_colons method.resource.controller.name + '::' + method.method
    end

    def swagger_id_for_typename(typename)
      typename
    end

    def swagger_op_id_for_path(http_method, path)
      # using lowercase http method, because the 'swagger-codegen' tool outputs
      # strange method names if the http method is in uppercase
      http_method.downcase + path.gsub(/\//, '_').gsub(/:(\w+)/, '\1').gsub(/_$/, '')
    end

    class SwaggerTypeWithFormat
      attr_reader :str_format
      def initialize(type, str_format)
        @type = type
        @str_format = str_format
      end

      def to_s
        @type
      end

      def ==(other)
        other.to_s == self.to_s
      end
    end

    def lookup
      @lookup ||= {
        numeric: 'number',
        hash: 'object',
        array: 'array',

        # see https://github.com/OAI/OpenAPI-Specification/blob/master/versions/2.0.md#data-types
        integer: SwaggerTypeWithFormat.new('integer', 'int32'),
        long: SwaggerTypeWithFormat.new('integer', 'int64'),
        number: SwaggerTypeWithFormat.new('number', nil),  # here just for completeness
        float: SwaggerTypeWithFormat.new('number', 'float'),
        double: SwaggerTypeWithFormat.new('number', 'double'),
        string: SwaggerTypeWithFormat.new('string', nil),  # here just for completeness
        byte: SwaggerTypeWithFormat.new('string', 'byte'),
        binary: SwaggerTypeWithFormat.new('string', 'binary'),
        boolean: SwaggerTypeWithFormat.new('boolean', nil), # here just for completeness
        date: SwaggerTypeWithFormat.new('string', 'date'),
        dateTime: SwaggerTypeWithFormat.new('string', 'date-time'),
        password: SwaggerTypeWithFormat.new('string', 'password'),
        oneOf: SwaggerTypeWithFormat.new('oneOf', nil)
      }
    end

    def swagger_param_type(param_desc)
      raise 'problem' if param_desc.nil?

      v = param_desc.validator
      return 'string' if v.nil?

      if v.class == Apipie::Validator::EnumValidator || (v.respond_to?(:is_enum?) && v.is_enum?)
        if v.values - [true, false] == [] && [true, false] - v.values == []
          warn_inferring_boolean(param_desc.name)
          return 'boolean'
        else
          return 'enum'
        end
      elsif v.class == Apipie::Validator::HashValidator
        # pp v
      end

      lookup_type = v.respond_to?(:swagger_type) ? v.swagger_type : v.expected_type
      lookup[lookup_type.to_sym] || lookup_type
    end

    #--------------------------------------------------------------------------
    # Responses
    #--------------------------------------------------------------------------

    def json_schema_for_method_response(method, return_code, allow_nulls)
      @schemas = {}
      method.returns.each do |response|
        next unless response.code.to_s == return_code.to_s

        schema = response_schema(response, allow_nulls)
        schema[:components] = { schemas: @schemas } if @schemas != {}
        return schema
      end
      nil
    end

    def json_schema_for_self_describing_class(cls, allow_nulls)
      adapter = ResponseDescriptionAdapter.from_self_describing_class(cls)
      response_schema(adapter, allow_nulls)
    end

    def response_schema(response, allow_nulls = false)
      begin
        # no need to warn about "missing default value for optional param" when processing response definitions
        prev_value = @disable_default_value_warning
        @disable_default_value_warning = true

        schema = if responses_use_reference? && response.typename
                   {
                     '$ref' => gen_referenced_block_from_params_array(swagger_id_for_typename(response.typename),
                                                                      response.params_ordered,
                                                                      allow_nulls)
                   }
                 else
                   json_schema_obj_from_params_array(response.params_ordered,
                                                     allow_nulls: allow_nulls,
                                                     title: response.response_name)
                 end
      ensure
        @disable_default_value_warning = prev_value
      end

      if response.is_array? && schema
        schema = {
          type: allow_nulls ? %w[array null] : 'array',
          items: schema
        }
      end

      schema[:additionalProperties] = true if response.allow_additional_properties

      schema
    end

    def swagger_responses_hash_for_method(method)
      result = {}

      method.errors.each do |error|
        error_block = { description: Apipie.app.translate(error.description, @current_lang) }
        result[error.code] = error_block
      end

      method.returns.each do |response|
        swagger_response_block = {
          description: response.description
        }

        schema = response_schema(response)
        if schema
          swagger_response_block[:content] = {
            'application/json' => {
              schema: schema
            }
          }
        end

        result[response.code] = swagger_response_block
      end

      if result.empty?
        warn_no_return_codes_specified
        result[200] = { description: 'ok' }
      end

      result
    end

    #--------------------------------------------------------------------------
    # Auto-insertion of parameters that are implicitly defined in the path
    #--------------------------------------------------------------------------

    def param_names_from_path(path)
      path.scan(/:(\w+)/).map do |ar|
        ar[0].to_sym
      end
    end

    def add_missing_params(method, path)
      param_names_from_method = method.params.map { |name, _| name }
      missing = param_names_from_path(path) - param_names_from_method

      result = method.params

      missing.each do |name|
        warn_path_parameter_not_described(name, path)
        result[name.to_sym] = OpenStruct.new({
                                               required: true,
                                               _gen_added_from_path: true,
                                               name: name,
                                               validator: Apipie::Validator::NumberValidator.new(nil),
                                               options: {
                                                 in: 'path'
                                               }
                                             })
      end

      result
    end

    #--------------------------------------------------------------------------
    # The core routine for creating a swagger parameter definition block.
    # The output is slightly different when the parameter is inside a schema block.
    #--------------------------------------------------------------------------
    def swagger_atomic_param(param_desc, in_schema, name, allow_nulls)
      swagger_def = {}
      swagger_def[:name] = name unless name.nil?

      swg_param_type = swagger_param_type(param_desc)
      swagger_def[:type] = swg_param_type.to_s
      if (swg_param_type.is_a? SwaggerTypeWithFormat) && !swg_param_type.str_format.nil?
        swagger_def[:format] = swg_param_type.str_format
      end

      case swagger_def[:type]
      when 'array'
        array_of_validator_opts = param_desc.validator.param_description.options
        items_type = array_of_validator_opts[:of] || array_of_validator_opts[:array_of]
        swagger_def[:items] = if items_type == Hash
                                {
                                  '$ref' => gen_referenced_block_from_params_array(
                                    ref_name_from_param_desc(param_desc),
                                    param_desc.validator.param_description.validator.params_ordered,
                                    allow_nulls
                                  )
                                }
                              elsif param_desc.validator.respond_to?(:items_validator) && param_desc.validator.items_validator
                                items_validator = param_desc.validator.items_validator
                                swagger_atomic_param(items_validator.param_description, true, nil, allow_nulls)
                              else
                                { type: 'string' }
                              end

      when 'enum'
        swagger_def[:type] = 'string'
        swagger_def[:enum] = param_desc.validator.values

      when 'oneOf'
        swagger_def.delete(:type)
        discriminator_mapping = {}

        swagger_def[:oneOf] = param_desc.validator.params_ordered.map.with_index do |param, ind|
          unless swagger_param_type(param) == 'object' && param.validator.params_ordered
            next swagger_atomic_param(param, true, nil, allow_nulls)
          end

          ref_path = gen_referenced_block_from_params_array(
            ref_name_from_param_desc(param, ind),
            param.validator.params_ordered,
            allow_nulls
          )

          discriminator_mapping[param.options[:discriminator]] = ref_path if param.options[:discriminator].present?

          {
            '$ref' => ref_path
          }
        end

        if param_desc.options[:discriminator_property].present?
          swagger_def[:discriminator] = {
            propertyName: param_desc.options[:discriminator_property],
            mapping: discriminator_mapping
          }
        end

        ref_name = ref_name_from_param_desc(param_desc)
        swagger_def = {
          **swagger_def.slice(:name, :description),
          '$ref' => put_schema_reference(ref_name, swagger_def.except(:name, :description))
        }

      when 'object' # we only get here if there is no specification of properties for this object
        swagger_def[:additionalProperties] = {}
        warn_hash_without_internal_typespec(param_desc.name)

      end

      if param_desc.is_array?
        new_swagger_def = {
          items: swagger_def,
          type: 'array'
        }
        swagger_def = new_swagger_def
        swagger_def[:type] = [swagger_def[:type], 'null'] if allow_nulls
      end

      swagger_def[:type] = [swagger_def[:type], 'null'] if allow_nulls

      unless in_schema
        swagger_def = { **swagger_def.slice(:name, :description), schema: swagger_def.except(:name, :description) }
        swagger_def[:in] = param_desc.options.fetch(:in, @default_value_for_param_in)
        swagger_def[:required] = param_desc.required if param_desc.required
        # This option maintains the default behaviour from v2 schemas where array params are encoded as ?foo=1,2,3
        # instead of ?foo=1&foo=2&foo=3
        swagger_def[:explode] = false if swagger_def[:schema][:type] == 'array'
      end

      save_field(swagger_def, :description, param_desc.options, :desc, true) unless param_desc.options[:desc].nil?
      save_field(in_schema ? swagger_def : swagger_def[:schema], :default, param_desc.options, :default_value)

      if param_desc.respond_to?(:_gen_added_from_path) && !param_desc.required
        warn_optional_param_in_path(param_desc.name)
        swagger_def[:required] = true
      end

      if !swagger_def[:required] && !swagger_def.key?(:default)
        warn_optional_without_default_value(param_desc.name) unless @disable_default_value_warning
      end

      swagger_def
    end

    def save_field(entry, openapi_key, v, apipie_key = openapi_key, translate = false)
      return unless v.key?(apipie_key)

      entry[openapi_key] = if translate
                             Apipie.app.translate(v[apipie_key], @current_lang)
                           else
                             v[apipie_key]
                           end
    end

    #--------------------------------------------------------------------------
    # JSON schema and referenced-object generation
    #--------------------------------------------------------------------------

    def ref_to(name)
      "#/components/schemas/#{name}"
    end

    def ref_name_from_param_desc(param_desc, name_fallback = '')
      op_id = swagger_op_id_for_path(param_desc.method_description.apis.first.http_method,
                                     param_desc.method_description.apis.first.path)
      "#{op_id}_param_#{param_desc.full_name || name_fallback}"
    end

    def put_schema_reference(name, schema_obj)
      @schemas[name.to_sym] = schema_obj unless @schemas.key(name.to_sym)
      ref_to(name.to_sym)
    end

    def json_schema_obj_from_params_array(params_array, allow_nulls: false, title: nil)
      (param_defs, required_params) = json_schema_param_defs_from_params_array(params_array,
                                                                               allow_nulls: allow_nulls,
                                                                               title_prefix: title)

      return nil if param_defs.empty?

      result = { type: 'object' }
      result[:properties] = param_defs
      result[:additionalProperties] = false unless Apipie.configuration.swagger_allow_additional_properties_in_response
      result[:required] = required_params unless required_params.empty?
      result[:title] = title unless title.nil?

      result
    end

    def gen_referenced_block_from_params_array(name, params_array, allow_nulls = false)
      return ref_to(name.to_sym) if @schemas.key(name.to_sym)

      schema_obj = json_schema_obj_from_params_array(params_array, allow_nulls: allow_nulls, title: name)
      return nil if schema_obj.nil?

      put_schema_reference(name, schema_obj)
    end

    def json_schema_param_defs_from_params_array(params_array, allow_nulls: false, title_prefix: nil)
      param_defs = {}
      required_params = []

      params_array ||= []

      params_array.each do |param_desc|
        raise 'unexpected param_desc format' unless param_desc.respond_to?(:required)

        required_params.push(param_desc.name.to_sym) if param_desc.required

        param_type = swagger_param_type(param_desc)

        if param_type == 'object' && param_desc.validator.params_ordered
          title = if title_prefix
                    "#{title_prefix}_#{param_desc.name}"
                  else
                    param_desc.name
                  end
          schema = json_schema_obj_from_params_array(param_desc.validator.params_ordered,
                                                     allow_nulls: allow_nulls,
                                                     title: title)

          schema[:additionalProperties] = true if param_desc.additional_properties

          if param_desc.is_array?
            new_schema = {
              type: 'array',
              items: schema
            }
            schema = new_schema
          end

          if allow_nulls
            # ideally we would write schema[:type] = ["object", "null"]
            # but due to a bug in the json-schema gem, we need to use anyOf
            # see https://github.com/ruby-json-schema/json-schema/issues/404
            new_schema = {
              anyOf: [schema, { type: 'null' }]
            }
            schema = new_schema
          end

          param_defs[param_desc.name.to_sym] = schema unless schema.nil?
        else
          param_defs[param_desc.name.to_sym] = swagger_atomic_param(param_desc, true, nil, allow_nulls)
        end
      end

      [param_defs, required_params]
    end

    #--------------------------------------------------------------------------
    # swagger "Params" block generation
    #--------------------------------------------------------------------------

    def body_allowed_for_current_method
      !%w[get head].include?(@current_http_method)
    end

    def request_body_types
      @request_body_types ||= if json_body?
                                %w[application/json]
                              else
                                %w[application/x-www-form-urlencoded multipart/form-data]
                              end
    end

    def swagger_request_body_for_method(method, path)
      return nil unless body_allowed_for_current_method

      all_params_hash = add_missing_params(method, path)
      body_param_defs_array = all_params_hash.map do |k, v|
        v unless param_names_from_path(path).include?(k)
      end.reject(&:nil?)

      name = "#{swagger_op_id_for_method(method)}_input"

      if params_in_body_use_reference?
        referenced_block = gen_referenced_block_from_params_array(name, body_param_defs_array)
        swagger_schema_for_body = { '$ref' => referenced_block } if referenced_block.present?
      else
        swagger_schema_for_body = json_schema_obj_from_params_array(body_param_defs_array, title: name)
      end

      return nil if swagger_schema_for_body.nil?

      {
        content: request_body_types.to_h { |type| [type, { schema: swagger_schema_for_body }] }
      }
    end

    def swagger_params_array_for_method(method, path)
      swagger_result = []
      all_params_hash = add_missing_params(method, path)
      path_param_names = param_names_from_path(path)

      path_param_defs_hash, body_param_defs_hash = all_params_hash.partition do |k, _|
        path_param_names.include?(k)
      end.map(&:to_h)

      path_param_defs_hash.each { |_, desc| desc.required = true }
      add_params_from_hash(swagger_result, path_param_defs_hash, nil, 'path')

      add_params_from_hash(swagger_result, body_param_defs_hash) unless body_allowed_for_current_method

      add_headers_from_hash(swagger_result, method.headers) if method.headers.present?

      swagger_result
    end

    def add_headers_from_hash(swagger_params_array, headers)
      swagger_headers = headers.map do |header|
        header_hash = {
          name: header[:name],
          in: 'header',
          required: !!header[:options][:required],
          description: header[:description],
          schema: {
            type: header[:options][:type] || 'string'
          }
        }
        header_hash[:schema][:default] = header[:options][:default] if header[:options][:default]
        header_hash
      end
      swagger_params_array.push(*swagger_headers)
    end

    def add_params_from_hash(swagger_params_array, param_defs, prefix = nil, default_value_for_in = nil)
      @default_value_for_param_in = default_value_for_in || 'query'

      param_defs.each do |name, desc|
        name = "#{prefix}[#{name}]" unless prefix.nil?

        if swagger_param_type(desc) == 'object'
          if desc.validator.params_ordered
            params_hash = Hash[desc.validator.params_ordered.map { |param| [param.name, param] }]
            add_params_from_hash(swagger_params_array, params_hash, name)
          else
            warn_param_ignored_in_form_data(desc.name)
          end
        else
          param_entry = swagger_atomic_param(desc, false, name, false)
          if param_entry[:required]
            swagger_params_array.unshift(param_entry)
          else
            swagger_params_array.push(param_entry)
          end
        end
      end
    end
  end
end
