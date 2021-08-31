require 'spec_helper'
require 'json-schema'

require File.expand_path('../../../dummy/app/controllers/pets_one_of_controller.rb', __FILE__)

describe 'nested hash swagger gen' do
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
      expect(apidoc_swagger_json).to match_json_schema(swagger_schema)
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

      puts JSON.dump(schemas)

      expect(schemas.dig(:get_pets_param_dog, :properties, :numeric_attributes, :type)).to eq 'object'
      expect(schemas.dig(:get_pets_param_dog, :properties, :numeric_attributes, :additionalProperties)).to eq("type" => "integer", "format" => "int64")

      expect(schemas.dig(:get_pets_param_cat, :properties, :meow_types, :additionalProperties, :'$ref')).to eq "#/components/schemas/get_pets_param_cat_meow_types_values"
      expect(schemas.dig(:get_pets_param_cat_meow_types_values, :type)).to eq 'object'
      expect(schemas.dig(:get_pets_param_cat_meow_types_values, :properties).keys).to match_array %w[volume tone timbre]
    end
  end
end
