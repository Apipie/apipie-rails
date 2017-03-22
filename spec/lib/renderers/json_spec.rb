require 'spec_helper'
require 'pry'

describe 'rake render' do
  include_context "rake"

  let(:doc_path)  { "user_specified_doc_path" }

  before do
    Apipie.configuration.doc_path = doc_path
    allow(Apipie).to receive(:reload_documentation)
    subject.invoke(*task_args)
  end

  describe 'json pages' do

    let(:json_doc) do
      JSON.parse(File.read(json_path))
    end

    let(:json_path) do
      "#{doc_output}/schema_apipie.json"
    end

    let(:doc_output) do
      File.join(::Rails.root, doc_path, 'apidoc')
    end

    after do
      Dir["#{doc_output}*"].each { |json_file| FileUtils.rm_rf(json_file) }
    end

    describe 'apipie:render:json' do
      it "generates json files for the default version of apipie docs" do
        binding.pry
        expect(File).to exist(json_path)
        expect(json_doc['docs']['name']).to match(/Test app/)
        expect(json_doc['docs']['info']).to match(/#{Apipie.configuration.default_version}/)
      end

    end

    describe 'apipie:render:json[2.0]' do
      it "generates json files for the default version of apipie docs" do
        expect(File).to exist(json_path)
        expect(json_doc['docs']['name']).to match(/Test app/)
        expect(json_doc['docs']['info']).to match(/2.0/)
      end
    end
  end

end
