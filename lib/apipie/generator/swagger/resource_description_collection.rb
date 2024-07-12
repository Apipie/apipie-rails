class Apipie::Generator::Swagger::ResourceDescriptionsCollection
  # @param [Hash{String->Apipie::ResourceDescription}] resource_descriptions
  def initialize(resource_descriptions)
    @resource_descriptions = resource_descriptions
  end

  # @return [Array<Apipie::ResourceDescription>]
  def filter(version:, resource_id:, method_name: nil)
    resources = []

    # If resource_id is blank, take just resources which have some methods because
    # we dont want to show eg ApplicationController as resource
    # otherwise, take only the specified resource
    @resource_descriptions[version].each do |resource_description_id, resource_description|
      if (resource_id.blank? && resource_description._methods.present?) || resource_description_id == resource_id
        resources << resource_description
      end
    end

    if method_name.present?
      resources = resources.select do |resource_description|
        resource_description._methods.any? do |method_description_name, _|
          method_description_name == method_name
        end
      end
    end

    resources
  end
end
