require 'spec_helper'

describe Apipie::Generator::Swagger::Schema do
  let(:version) { :ok }
  let(:language) { :ok }
  let(:clear_warnings) { :ok }
  let(:dsl_data) { {} }
  let(:resource_id) { 'pets' }
  let(:resource_descriptions) { [resource_description] }

  let(:resource_description) do
    Apipie::ResourceDescription.new(PetsController, resource_id, dsl_data)
  end

  let(:schema_generator) do
    described_class.new(
      resource_descriptions,
      version: version,
      language: language,
      clear_warnings: clear_warnings
    )
  end

  describe '#generate' do
    subject(:schema) { schema_generator.generate }

    describe 'host' do
      before { Apipie.configuration.generator.swagger.api_host = nil }

      it 'is not returned' do
        expect(schema.keys).not_to include(:host)
      end

      context 'when api_host is set' do
        let(:host) { 'localhost:3000' }

        before { Apipie.configuration.generator.swagger.api_host = host }

        it 'returns the host' do
          expect(schema[:host]).to eq(host)
        end
      end
    end

    describe 'consumes' do
      subject { schema_generator.generate[:consumes] }

      before { Apipie.configuration.generator.swagger.content_type_input = nil }

      it { is_expected.to eq(['application/x-www-form-urlencoded', 'multipart/form-data']) }

      context 'when swagger.content_type_input is set to json' do
        before { Apipie.configuration.generator.swagger.content_type_input = :json }

        it { is_expected.to eq(['application/json']) }
      end
    end

    describe 'title' do
      subject { schema_generator.generate[:info][:title] }

      before { Apipie.configuration.generator.swagger.content_type_input = nil }

      it { is_expected.to include(' (params in:formData)') }

      context 'when swagger.content_type_input is set to json' do
        before { Apipie.configuration.generator.swagger.content_type_input = :json }

        it { is_expected.to include(' (params in:body)') }
      end
    end

    describe 'x-computed-id' do
      subject(:schema) { schema_generator.generate[:info] }

      before { Apipie.configuration.generator.swagger.generate_x_computed_id_field = false }

      it 'is not returned' do
        expect(schema.keys).not_to include('x-computed-id')
      end

      context 'when swagger.content_type_input is set to json' do
        before { Apipie.configuration.generator.swagger.generate_x_computed_id_field = true }

        it { is_expected.to include('x-computed-id') }
      end
    end
  end
end
