class Apipie::Generator::Swagger::ResourceDescriptionComposite
  # @param [Array<Apipie::ResourceDescription>] resource_descriptions
  def initialize(resource_descriptions, language:)
    @resource_descriptions = resource_descriptions
    @language = language
  end

  # @return [Hash{Symbol->Array | Hash}]
  def to_swagger
    {
      tags: tags,
      paths: paths
    }
  end

  # @return [Array]
  def tags
    results = []

    @resource_descriptions.each do |resource_description|
      next unless resource_description._full_description

      results << {
        name: resource_description._id,
        description: Apipie.app.translate(
          resource_description._full_description,
          @language
        )
      }
    end

    results
  end

  # @return [Hash]
  def paths
    results = {}

    @resource_descriptions.each do |resource_description|
      resource_description._methods.each_value do |method_description|
        next unless method_description.show

        result = Apipie::Generator::Swagger::MethodDescription::ApiSchemaService
                 .new(
                   Apipie::Generator::Swagger::MethodDescription::Decorator.new(method_description),
                   language: @language
                 )
                 .call

        results.deep_merge!(result)
      end
    end

    results
  end
end
