class Apipie::Generator::Swagger::ResourceDescriptionsCollection
  # @param [Hash{String->Apipie::ResourceDescription}] resource_descriptions
  def initialize(resource_descriptions)
    @resource_descriptions = resource_descriptions
  end

  # @return [Array<Apipie::ResourceDescription>]
  def filter(version:, resource_name:, method_name: nil)
    resources = []

    # If resource_name is blank, take just resources which have some methods because
    # we dont want to show eg ApplicationController as resource
    # otherwise, take only the specified resource
    @resource_descriptions[version].each do |resource_description_name, resource_description|
      if (resource_name.blank? && resource_description._methods.present?) || resource_description_name == resource_name
        resources << resource_description
      end
    end

    if method_name.present?
      resources = resources.select do |resource_description|
        resource_description._methods.select do |method_description_name, _|
          method_description_name == method_name
        end.present?
      end
    end

    resources
  end
end
