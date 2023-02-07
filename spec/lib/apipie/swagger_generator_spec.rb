require 'spec_helper'
require 'dummy/app/controllers/pets_using_self_describing_classes_controller'

describe Apipie::SwaggerGenerator do
  describe '.json_schema_for_self_describing_class' do
    subject(:schema) do
      described_class.json_schema_for_self_describing_class(
        self_describing_class,
        allow_null
      )
    end

    let(:self_describing_class) { PetWithMeasurements }
    let(:allow_null) { false }

    before { Apipie.configuration.swagger_responses_use_refs = false }

    it 'returns the self describing class schema' do
      expect(schema.keys).to include(:type, :properties, :required)
      expect(schema[:properties].keys).to include(:pet_name, :animal_type, :pet_measurements)
    end
  end
end
