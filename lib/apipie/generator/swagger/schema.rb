class Apipie::Generator::Swagger::Schema
  # @param [Array<Apipie::ResourceDescription>] resource_descriptions
  def initialize(resource_descriptions, version:, language:, clear_warnings:)
    @resource_descriptions = resource_descriptions
    @language = language
    @clear_warnings = clear_warnings
    @swagger = {
      swagger: '2.0',
      info: {
        title: Apipie.configuration.app_name.to_s,
        description: "#{Apipie.app_info(version, @language)}#{Apipie.configuration.copyright}",
        version: version.to_s,
        'x-copyright': Apipie.configuration.copyright
      },
      basePath: Apipie.api_base_url(version),
      consumes: [],
      paths: {},
      definitions: {},
      schemes: Apipie.configuration.generator.swagger.schemes,
      tags: [],
      securityDefinitions: Apipie.configuration.generator.swagger.security_definitions,
      security: Apipie.configuration.generator.swagger.global_security
    }
  end

  def generate
    if Apipie.configuration.generator.swagger.api_host.present?
      @swagger[:host] = Apipie.configuration.generator.swagger.api_host
    end

    if Apipie.configuration.generator.swagger.content_type_input == :json
      @swagger[:consumes] = ['application/json']
      @swagger[:info][:title] += ' (params in:body)'
    else
      @swagger[:consumes] = ['application/x-www-form-urlencoded', 'multipart/form-data']
      @swagger[:info][:title] += ' (params in:formData)'
    end

    if @clear_warnings
      Apipie::Generator::Swagger::WarningWriter.instance.clear!
    end

    @swagger.merge!(tags_and_paths)

    if Apipie.configuration.generator.swagger.generate_x_computed_id_field?
      @swagger[:info]['x-computed-id'] =
        Apipie::Generator::Swagger::ComputedInterfaceId.instance.id
    end

    @swagger[:definitions] =
      Apipie::Generator::Swagger::ReferencedDefinitions.instance.definitions

    @swagger
  end

  private

  def tags_and_paths
    Apipie::Generator::Swagger::ResourceDescriptionComposite
      .new(@resource_descriptions, language: @language)
      .to_swagger
  end
end
