require 'spec_helper'
require 'json-schema'

require File.expand_path('../../../dummy/app/controllers/pets_one_of_controller.rb', __FILE__)

describe 'one of swagger gen' do
  include_context 'rake'

  let(:doc_path) { 'user_specified_doc_path' }

  before do
    Apipie.configuration.doc_path = doc_path
    Apipie.configuration.swagger_suppress_warnings = true
    allow(Apipie).to receive(:reload_documentation)
    subject.invoke(*task_args)
  end

  after do
    Dir["#{doc_output}*"].each { |static_file| FileUtils.rm_rf(static_file) }
  end

  let(:swagger_schema) do
    File.read(File.join(File.dirname(__FILE__), 'openapi_3_0_schema.json'))
  end

  let(:apidoc_swagger_json) do
    # note:  the filename ends with '_tmp' because this suffix is passed as a parameter to the rake task
    File.read("#{doc_output}/schema_swagger_tmp.json")
  end

  let(:apidoc_swagger) do
    HashWithIndifferentAccess.new(JSON.parse(apidoc_swagger_json))
  end

  let(:doc_output) do
    File.join(::Rails.root, doc_path, 'apidoc')
  end

  describe 'apipie:static_swagger_json[development,json,_tmp]' do
    it 'generates a valid swagger file' do
      expect(JSON::Validator.validate(swagger_schema, apidoc_swagger_json)).to be_truthy
    end

    it 'generates static swagger files for the default version of apipie docs' do
      expect(apidoc_swagger['info']['title']).to eq('Test app (params in:body)')
      expect(apidoc_swagger['info']['version']).to eq Apipie.configuration.default_version.to_s
    end

    it 'includes expected paths' do
      paths = apidoc_swagger['paths']
      expect(paths['/pets'].values.count).to be 2
      expect(paths['/pets/{id}'].values.count).to be 1
    end

    it 'includes expected schemas' do
      schemas = apidoc_swagger['components']['schemas']

      expect(schemas['get_pets_param_tag_id']['oneOf']).to match_array [{ type: 'integer', format: 'int64' },
                                                                        { type: 'string' }]

      expect(schemas['get_pets_param_data']['oneOf']).to match_array [{ "$ref": '#/components/schemas/get_pets_param_dog' },
                                                                      { "$ref": '#/components/schemas/get_pets_param_cat' }]
      expect(schemas['get_pets_param_data']['discriminator']['propertyName']).to eq 'animal_type'
      expect(schemas['get_pets_param_data']['discriminator']['mapping'].keys).to match_array %w[dog cat]

      expect(schemas['get_pets_param_dog']['type']).to eq 'object'
      expect(schemas['get_pets_param_cat']['type']).to eq 'object'

      expect(schemas.dig(:created_by_day_response, :properties, :data, :type)).to eq 'array'
      expect(schemas.dig(:created_by_day_response, :properties, :data, :items, :type)).to eq 'array'
      expect(schemas.dig(:created_by_day_response, :properties, :data, :items, :items, :'$ref')).to eq '#/components/schemas/get_pets_created_by_day_param_point'
    end
  end
end
