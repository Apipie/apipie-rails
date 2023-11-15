require 'spec_helper'
require 'dummy/app/controllers/pets_using_self_describing_classes_controller'

describe Apipie::SwaggerGenerator do
  describe '.json_schema_for_method_response' do
    subject { json_schema_for_method_response }

    let(:response_description_dsl) do
      proc do
        property :a_number, Integer, example: 1
        property :an_optional_number, Integer, required: false
      end
    end

    let(:response_description_options) do
      [{}, PetsController, response_description_dsl, nil]
    end

    let(:dsl_data) do
      ActionController::Base
        .send(:_apipie_dsl_data_init)
        .merge(
          {
            returns: [[200, response_description_options]],
            api_args: [
              ['get', '/path', 'Some api description', { deprecated: true }]
            ]
          }
        )
    end

    let(:method_description) do
      Apipie::MethodDescription.new(
        :show,
        Apipie::ResourceDescription.new(UsersController, 'users'),
        dsl_data
      )
    end

    let(:json_schema_for_method_response) do
      described_class.json_schema_for_method_response(
        method_description,
        return_code,
        false
      )
    end

    context 'when there is no return code for responses' do
      let(:return_code) { 3000 }

      it { is_expected.to be_nil }
    end

    context 'when return code exists' do
      let(:return_code) { 200 }

      describe 'properties' do
        subject(:properties) { json_schema_for_method_response[:properties] }

        it 'returns correct properties' do
          expect(properties).to eq(
            {
              a_number: {
                type: 'number', required: true, example: 1
              },
              an_optional_number: {
                type: 'number'
              }
            }
          )
        end
      end
    end
  end

  describe '.json_schema_for_self_describing_class' do
    subject(:schema) do
      described_class.json_schema_for_self_describing_class(
        self_describing_class,
        allow_null
      )
    end

    let(:self_describing_class) { PetWithMeasurements }
    let(:allow_null) { false }

    before { Apipie.configuration.generator.swagger.responses_use_refs = false }

    it 'returns the self describing class schema' do
      expect(schema.keys).to include(:type, :properties, :required)
      expect(schema[:properties].keys).to include(:pet_name, :animal_type, :pet_measurements)
    end
  end
end
