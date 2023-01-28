module Apipie
  class SwaggerGenerator
    def initialize(apipie)
      @apipie = apipie
    end

    def generate_from_resources(version, resources, method_name, lang, clear_warnings=false)
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

      if Apipie.configuration.swagger_api_host.present?
        @swagger[:host] = Apipie.configuration.swagger_api_host
      end

      if Apipie.configuration.swagger_content_type_input == :json
        @swagger[:consumes] = ['application/json']
        @swagger[:info][:title] += " (params in:body)"
      else
        @swagger[:consumes] = ['application/x-www-form-urlencoded', 'multipart/form-data']
        @swagger[:info][:title] += " (params in:formData)"
      end

      if clear_warnings
        Apipie::Generator::Swagger::WarningWriter.instance.clear!
      end

      @current_lang = lang

      @only_method = method_name
      add_resources(resources)

      if Apipie.configuration.swagger_generate_x_computed_id_field?
        @swagger[:info]["x-computed-id"] = computed_interface_id
      end

      @swagger[:definitions] = Apipie::Generator::Swagger::ReferencedDefinitions.
        instance.
        definitions

      @swagger
    end

    def computed_interface_id
      Apipie::Generator::Swagger::ComputedInterfaceId.instance.id
    end

    #--------------------------------------------------------------------------
    # Engine interface methods
    #--------------------------------------------------------------------------

    def add_resources(resources)
      resources.each do |_, resource_defs|
        add_resource_description(resource_defs)
        add_resource_methods(resource_defs)
      end
    end

    def add_resource_methods(resource_defs)
      resource_defs._methods.each do |_, apipie_method_defs|
        @swagger[:paths].deep_merge!(add_ruby_method(apipie_method_defs))
      end
    end


    #--------------------------------------------------------------------------
    # Create a tag description for a described resource
    #--------------------------------------------------------------------------

    def add_resource_description(resource)
      if resource._full_description
        @swagger[:tags] << {
            name:  resource._id,
            description: Apipie.app.translate(resource._full_description, @current_lang)
        }
      end
    end

    #--------------------------------------------------------------------------
    # Create swagger definitions for a ruby method
    #--------------------------------------------------------------------------

    # @param [Apipie::MethodDescription] ruby_method
    #
    # @return [Hash]
    def add_ruby_method(ruby_method)
      if @only_method
        return {} unless ruby_method.method == @only_method
      else
        return {} if !ruby_method.show
      end

      ruby_method = Apipie::Generator::Swagger::MethodDescription::Decorator.
        new(ruby_method)

      Apipie::Generator::Swagger::MethodDescription::ApiSchemaService.
        new(ruby_method, language: @current_lang).
        call
    end

    #--------------------------------------------------------------------------
    # Responses
    #--------------------------------------------------------------------------

    def json_schema_for_method_response(method, return_code, allow_nulls)
      response = method.returns.find { |response| response.code.to_s == return_code.to_s }

      return if response.blank?

      http_method = method.apis.first.http_method

      schema = Apipie::Generator::Swagger::MethodDescription::ResponseSchemaService.new(
        response,
        allow_null: allow_nulls,
        http_method: http_method,
        controller_method: method
      ).to_swagger

      definitions = Apipie::Generator::Swagger::ReferencedDefinitions.instance.definitions

      if definitions.present?
        schema[:definitions] = definitions
      end

      schema
    end

    def self.json_schema_for_self_describing_class(cls, allow_nulls)
      Apipie::Generator::Swagger::MethodDescription::ResponseSchemaService.new(
        ResponseDescriptionAdapter.from_self_describing_class(cls),
        allow_null: allow_nulls,
        http_method: nil,
        controller_method: nil
      ).to_swagger
    end
  end
end
