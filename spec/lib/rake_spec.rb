require 'spec_helper'

describe 'rake tasks' do
  include_context "rake"

  let(:doc_path)  { 'tmp/user_specified_doc_path' }

  before do
    Apipie.configuration.doc_path = doc_path
    allow(Apipie).to receive(:reload_documentation)
    subject.invoke(*task_args)
  end

  describe 'static pages' do

    let(:apidoc_html) do
      File.read("#{doc_output}.html")
    end

    let(:doc_output) do
      File.join(Rails.root, doc_path, 'apidoc')
    end

    after do
      Dir["#{doc_output}*"].each { |static_file| FileUtils.rm_rf(static_file) }
    end

    describe 'apipie:static' do
      it "generates static files for the default version of apipie docs" do
        expect(apidoc_html).to match(/Test app #{Apipie.configuration.default_version}/)
      end

      it "includes the stylesheets" do
        expect(apidoc_html).to include('./apidoc/stylesheets/bundled/bootstrap.min.css')
        expect(File).to exist(File.join(doc_output, 'stylesheets/bundled/bootstrap.min.css'))
      end
    end

    describe 'apipie:static[2.0]' do
      it "generates static files for the default version of apipie docs" do
        expect(apidoc_html).to match(/Test app 2.0/)
      end

      it "includes the stylesheets" do
        expect(apidoc_html).to include('./apidoc/stylesheets/bundled/bootstrap.min.css')
        expect(File).to exist(File.join(doc_output, 'stylesheets/bundled/bootstrap.min.css'))
      end
    end
  end

  describe 'apipie:cache' do
    let(:cache_output) { Apipie.configuration.cache_dir }

    let(:apidoc_html) do
      File.read("#{cache_output}.html")
    end

    after do
      Dir["#{cache_output}*"].each { |static_file| FileUtils.rm_rf(static_file) }
    end

    it "generates cache files" do
      expect(File).to exist(File.join(cache_output, 'apidoc.html'))
      expect(File).to exist(File.join(cache_output, 'apidoc/development.html'))
      expect(File).to exist(File.join(cache_output, 'apidoc/development/users.html'))

    end
  end
end
