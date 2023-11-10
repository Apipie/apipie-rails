require 'spec_helper'

describe Apipie::Generator::Swagger::MethodDescription::ResponseSchemaService do
  let(:http_method) { nil }
  let(:controller_method) { nil }
  let(:allow_null) { false }

  let(:resource_description) do
    Apipie::ResourceDescription.new(PetsController, 'pets')
  end

  let(:method_description) do
    Apipie::MethodDescription.new(
      'create',
      resource_description,
      ActionController::Base.send(:_apipie_dsl_data_init)
    )
  end

  let(:response_description_dsl) do
    proc do
      property :a_number, Integer, example: 1
      property :an_optional_number, Integer, required: false, example: 2
    end
  end

  let(:options) { {} }

  let(:response_description) do
    Apipie::ResponseDescription.new(
      method_description,
      204,
      options,
      PetsController,
      response_description_dsl,
      nil
    )
  end

  let(:service) do
    described_class.new(
      response_description,
      allow_null: allow_null,
      http_method: http_method,
      controller_method: controller_method
    )
  end

  describe '#to_swagger' do
    let(:swagger_response) { service.to_swagger }

    describe 'properties' do
      subject(:properties) { swagger_response[:properties] }

      it 'returns correct properties' do
        expect(properties).to eq(
          {
            a_number: {
              type: 'number', required: true, example: 1
            },
            an_optional_number: {
              type: 'number', example: 2
            }
          }
        )
      end

      context 'when nulls are allowed' do
        let(:allow_null) { true }

        it 'returns correct properties' do
          expect(properties).to eq(
            {
              a_number: {
                type: %w[number null], required: true, example: 1
              },
              an_optional_number: {
                type: %w[number null], example: 2
              }
            }
          )
        end
      end
    end

    context 'when responses_use_refs is set to true' do
      subject(:response) { swagger_response }

      before { Apipie.configuration.generator.swagger.responses_use_refs = true }
      after { Apipie.configuration.generator.swagger.responses_use_refs = false }

      context 'when typename is given' do
        let(:options) { { param_group: :some_param_group } }

        it 'returns the reference' do
          expect(response).to eq(
            {
              '$ref' => '#/definitions/some_param_group'
            }
          )
        end
      end
    end
  end
end
