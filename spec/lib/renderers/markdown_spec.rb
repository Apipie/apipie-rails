require 'spec_helper'

describe 'rake render' do
  include_context "rake"

  let(:doc_path)  { "user_specified_doc_path" }

  before do
    Apipie.configuration.doc_path = doc_path
    allow(Apipie).to receive(:reload_documentation)
    subject.invoke(*task_args)
  end

  describe 'markdown pages' do

    let(:apidoc_md) do
      File.read("#{doc_output}/apidoc-onepage.md")
    end

    let(:doc_output) do
      File.join(::Rails.root, doc_path)
    end

    after do
      Dir["#{doc_output}*"].each { |markdown_file| FileUtils.rm_rf(markdown_file) }
    end

    describe 'apipie:render:markdown' do
      it "generates markdown files for the default version of apipie docs" do
        expect(apidoc_md).to match(/# Test app/)
        expect(apidoc_md).to match(/Dummy app for #{Apipie.configuration.default_version}/)
      end

    end

    describe 'apipie:render:markdown[2.0]' do
      it "generates markdown files for the default version of apipie docs" do
        expect(apidoc_md).to match(/# Test app/)
        expect(apidoc_md).to match(/Version 2.0 description/)
      end

    end
  end

end
