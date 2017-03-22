require 'spec_helper'

describe 'rake render' do
  include_context "rake"

  let(:doc_path)  { "user_specified_doc_path" }

  before do
    Apipie.configuration.doc_path = doc_path
    allow(Apipie).to receive(:reload_documentation)
    subject.invoke(*task_args)
  end

  describe 'html pages' do

    let(:apidoc_html) do
      File.read("#{doc_output}.html")
    end

    let(:doc_output) do
      File.join(::Rails.root, doc_path, 'apidoc')
    end

    after do
      Dir["#{doc_output}*"].each { |html_file| FileUtils.rm_rf(html_file) }
    end

    describe 'apipie:render:html' do
      it "generates html files for the default version of apipie docs" do
        expect(apidoc_html).to match(/Test app #{Apipie.configuration.default_version}/)
      end

      it "includes the stylesheets" do
        expect(apidoc_html).to include('./apidoc/stylesheets/bundled/bootstrap.min.css')
        expect(File).to exist(File.join(doc_output, 'stylesheets/bundled/bootstrap.min.css'))
      end
    end

    describe 'apipie:render:html[2.0]' do
      it "generates html files for the default version of apipie docs" do
        expect(apidoc_html).to match(/Test app 2.0/)
      end

      it "includes the stylesheets" do
        expect(apidoc_html).to include('./apidoc/stylesheets/bundled/bootstrap.min.css')
        expect(File).to exist(File.join(doc_output, 'stylesheets/bundled/bootstrap.min.css'))
      end
    end
  end

end
