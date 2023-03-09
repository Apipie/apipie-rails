module Apipie

  #--------------------------------------------------------------------------
  # Configuration.  Should be moved to Apipie config.
    #--------------------------------------------------------------------------
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

    def params_in_body?
      Apipie.configuration.swagger_content_type_input == :json
    end

    def include_warning_tags?
      Apipie.configuration.swagger_include_warning_tags
    end

    def generate_from_resources(version, resources, method_name, lang, clear_warnings=false)
      init_swagger_vars(version, lang, clear_warnings)

      @only_method = method_name
      add_resources(resources)

      @swagger[:info]["x-computed-id"] = @computed_interface_id if Apipie.configuration.swagger_generate_x_computed_id_field?
      @swagger[:definitions] = Apipie::Generator::Swagger::ReferencedDefinitions.
        instance.
        definitions

      @swagger
    end


    #--------------------------------------------------------------------------
    # Initialization
    #--------------------------------------------------------------------------

    def init_swagger_vars(version, lang, clear_warnings=false)
      @swagger = {
          swagger: '2.0',
          info: {
              title: "#{Apipie.configuration.app_name}",
              description: "#{Apipie.app_info(version, lang)}#{Apipie.configuration.copyright}",
              version: "#{version}",
              "x-copyright" => Apipie.configuration.copyright,
          },
          basePath: Apipie.api_base_url(version),
          consumes: [],
          paths: {},
          definitions: {},
          schemes: Apipie.configuration.swagger_schemes,
          tags: [],
          securityDefinitions: Apipie.configuration.swagger_security_definitions,
          security: Apipie.configuration.swagger_global_security
      }

      if Apipie.configuration.swagger_api_host
        @swagger[:host] = Apipie.configuration.swagger_api_host
      end

      if params_in_body?
        @swagger[:consumes] = ['application/json']
        @swagger[:info][:title] += " (params in:body)"
      else
        @swagger[:consumes] = ['application/x-www-form-urlencoded', 'multipart/form-data']
        @swagger[:info][:title] += " (params in:formData)"
      end

      @paths = @swagger[:paths]
      @tags = @swagger[:tags]

      @issued_warnings = [] if clear_warnings || @issued_warnings.nil?
      @computed_interface_id = 0

      @current_lang = lang
    end

    #--------------------------------------------------------------------------
    # Engine interface methods
    #--------------------------------------------------------------------------

    def add_resources(resources)
      resources.each do |resource_name, resource_defs|
        add_resource_description(resource_name, resource_defs)
        add_resource_methods(resource_name, resource_defs)
      end
    end

    def add_resource_methods(resource_name, resource_defs)
      resource_defs._methods.each do |apipie_method_name, apipie_method_defs|
        add_ruby_method(@paths, apipie_method_defs)
      end
    end


    #--------------------------------------------------------------------------
    # Logging, debugging and regression-testing utilities
    #--------------------------------------------------------------------------

    def warn_missing_method_summary
      warn(Apipie::Generator::Swagger::Warning::MISSING_METHOD_SUMMARY_CODE)
    end

    def warn_added_missing_slash(path)
      warn(
        Apipie::Generator::Swagger::Warning::ADDED_MISSING_SLASH_CODE,
        { path: path }
      )
    end

    def warn_optional_param_in_path(param_name)
      warn(
        Apipie::Generator::Swagger::Warning::OPTIONAL_PARAM_IN_PATH_CODE,
        { parameter: param_name }
      )
    end

    def warn_optional_without_default_value(param_name)
      warn(
        Apipie::Generator::Swagger::Warning::OPTIONAL_WITHOUT_DEFAULT_VALUE_CODE,
        { parameter: param_name }
      )
    end

    def warn_path_parameter_not_described(name, path)
      warn(
        Apipie::Generator::Swagger::Warning::PATH_PARAM_NOT_DESCRIBED_CODE,
        { name: name, path: path }
      )
    end

    def warn_inferring_boolean(name)
      warn(
        Apipie::Generator::Swagger::Warning::INFERRING_BOOLEAN_CODE,
        { name: name }
      )
    end

    # @param [Integer] warning_code
    # @param [Hash] message_attributes
    def warn(warning_code, message_attributes = {})
      Apipie::Generator::Swagger::Warning.for_code(
        warning_code,
        @current_method.ruby_name,
        message_attributes
      ).warn_through_writer

      @warnings_issued = Apipie::Generator::Swagger::WarningWriter.
        instance.
        issued_warnings?
    end

    def info(msg)
      print "--- INFO: [#{@current_method.ruby_name}] -- #{msg}\n"
    end


    # the @computed_interface_id is a number that is uniquely derived from the list of operations
    # added to the swagger definition (in an order-dependent way).
    # it can be used for regression testing, allowing some differentiation between changes that
    # result from changes to the input and those that result from changes to the generation
    # algorithms.
    # note that at the moment, this only takes operation ids into account, and ignores parameter
    # definitions, so it's only partially useful.
    def include_op_id_in_computed_interface_id(op_id)
      @computed_interface_id = Zlib::crc32("#{@computed_interface_id} #{op_id}") if Apipie.configuration.swagger_generate_x_computed_id_field?
    end

    #--------------------------------------------------------------------------
    # Create a tag description for a described resource
    #--------------------------------------------------------------------------

    def tag_name_for_resource(resource)
      # resource.controller
      resource._id
    end

    def add_resource_description(resource_name, resource)
      if resource._full_description
        @tags << {
            name: tag_name_for_resource(resource),
            description: Apipie.app.translate(resource._full_description, @current_lang)
        }
      end
    end

    #--------------------------------------------------------------------------
    # Create swagger definitions for a ruby method
    #--------------------------------------------------------------------------

    def add_ruby_method(paths, ruby_method)

      if @only_method
        return unless ruby_method.method == @only_method
      else
        return if !ruby_method.show
      end

      ruby_method = Apipie::Generator::Swagger::MethodDescription::Decorator.
        new(ruby_method)

      for api in ruby_method.apis do
        path = swagger_path(api.path)
        paths[path] ||= {}
        methods = paths[path]
        @current_method = ruby_method

        @warnings_issued = false

        responses = Apipie::Generator::Swagger::MethodDescription::ResponseService.
          new(
            ruby_method,
            language: @current_lang,
            http_method: api.http_method.downcase
          ).
          call

        if include_warning_tags?
          warning_tags = @warnings_issued ? ['warnings issued'] : []
        else
          warning_tags = []
        end

        op_id = Apipie::Generator::Swagger::OperationId.from(api).to_s

        include_op_id_in_computed_interface_id(op_id)

        method_key = api.http_method.downcase
        @current_http_method = method_key

        parameters = Apipie::Generator::Swagger::MethodDescription::ParametersService.
          new(
            ruby_method,
            path: Apipie::Generator::Swagger::PathDecorator.new(api.path),
            http_method: method_key
          ).call

        methods[method_key] = {
          tags: [tag_name_for_resource(ruby_method.resource)] + warning_tags + ruby_method.tag_list.tags,
          consumes: params_in_body? ? ['application/json'] : ['application/x-www-form-urlencoded', 'multipart/form-data'],
          operationId: op_id,
          summary: Apipie.app.translate(api.short_description, @current_lang),
          parameters: parameters,
          responses: responses,
          description: ruby_method.full_description
        }

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
      str = str.gsub(%r{/$}, '')

      if str[0] != '/'
        warn_added_missing_slash(str)
        str = '/' + str
      end
      str
    end

    def swagger_param_type(param_desc)
      if param_desc.blank?
        raise ArgumentError, 'param_desc is required'
      end

      method_id = @current_method.ruby_name

      warning = Apipie::Generator::Swagger::Warning.for_code(
        Apipie::Generator::Swagger::Warning::INFERRING_BOOLEAN_CODE,
        method_id,
        { parameter: param_desc.name }
      )

      Apipie::Generator::Swagger::TypeExtractor.new(param_desc.validator).
        extract_with_warnings({ boolean: warning })
    end


    #--------------------------------------------------------------------------
    # Responses
    #--------------------------------------------------------------------------

    def json_schema_for_method_response(method, return_code, allow_nulls)
      @definitions = {}
      for response in method.returns
        next unless response.code.to_s == return_code.to_s
        schema = response_schema(response, allow_nulls)
        schema[:definitions] = @definitions if @definitions != {}
        return schema
      end
      nil

      if response.is_array? && schema

      if response.allow_additional_properties



    #--------------------------------------------------------------------------
    # Auto-insertion of parameters that are implicitly defined in the path
    #--------------------------------------------------------------------------
      ).to_swagger

      return nil if schema_obj.nil?


      swagger_result
    end
      end

        if swagger_param_type(desc) == "object"
    end
  end

end
