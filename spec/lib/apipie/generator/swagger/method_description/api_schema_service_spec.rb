require 'spec_helper'

describe Apipie::Generator::Swagger::MethodDescription::ApiSchemaService do
  let(:path) { '/api' }
  let(:http_method) { 'get' }
  let(:resource_id) { 'users' }
  let(:method_description_description) { nil }
  let(:tags) { [] }

  let(:dsl_data) do
    ActionController::Base
      .send(:_apipie_dsl_data_init)
      .merge(
        {
          description: method_description_description,
          api_args: [[http_method, path, 'Some api description', { deprecated: true }]],
          tag_list: tags
        }
      )
  end

  let(:resource_desc) do
    Apipie::ResourceDescription.new(UsersController, resource_id)
  end

  let(:method_description) do
    Apipie::Generator::Swagger::MethodDescription::Decorator.new(
      Apipie::MethodDescription.new(:show, resource_desc, dsl_data)
    )
  end

  let(:service) { described_class.new(method_description) }

  describe '#call' do
    subject(:schema) { service.call }

    it 'returns the path' do
      expect(schema).to include(path)
    end

    it 'returns the http method' do
      expect(schema[path]).to include(http_method)
    end

    it 'returns the correct attributes' do
      expect(schema[path][http_method].keys).to include(
        :tags,
        :consumes,
        :operationId,
        :parameters,
        :responses
      )
    end
  end

  describe 'tags' do
    subject { service.call[path][http_method][:tags] }

    it { is_expected.to eq([resource_id]) }

    context 'when tags are available' do
      let(:tags) { ['Tag 1', 'Tag 2'] }

      it { is_expected.to include(*tags) }
    end

    context 'when Apipie.configuration.generator.swagger.skip_default_tags is enabled' do
      before { Apipie.configuration.generator.swagger.skip_default_tags = true }
      after { Apipie.configuration.generator.swagger.skip_default_tags = false }

      it { is_expected.to be_empty }

      context 'when tags are available' do
        let(:tags) { ['Tag 1', 'Tag 2'] }

        it { is_expected.to eq(tags) }
      end
    end

    context 'when Apipie.configuration.generator.swagger.include_warning_tags is enabled' do
      before { Apipie.configuration.generator.swagger.include_warning_tags = true }

      context 'when warnings are issued' do
        before do
          Apipie::Generator::Swagger::Warning.for_code(
            Apipie::Generator::Swagger::Warning::MISSING_METHOD_SUMMARY_CODE,
            'some_method'
          ).warn_through_writer
        end

        it { is_expected.to include('warnings issued') }
      end
    end
  end

  describe 'consumes' do
    subject { service.call[path]['get'][:consumes] }

    it { is_expected.to eq(['application/x-www-form-urlencoded', 'multipart/form-data']) }

    context 'when content type input is json' do
      before { Apipie.configuration.generator.swagger.content_type_input = :json }

      it { is_expected.to eq(['application/json']) }
    end
  end

  describe 'description' do
    subject { service.call[path]['get'][:description] }

    it { is_expected.to be_blank }

    context 'when description for method description exists' do
      let(:method_description_description) { 'Some description' }

      it { is_expected.to eq(method_description_description) }
    end
  end
end
