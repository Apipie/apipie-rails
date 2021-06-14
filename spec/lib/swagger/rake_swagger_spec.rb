require 'spec_helper'
require "json-schema"

require File.expand_path("../../../dummy/app/controllers/twitter_example_controller.rb", __FILE__)
require File.expand_path("../../../dummy/app/controllers/users_controller.rb", __FILE__)
require File.expand_path("../../../dummy/app/controllers/pets_controller.rb", __FILE__)

describe 'rake tasks' do
  include_context "rake"

  let(:doc_path)  { "user_specified_doc_path" }

  before do
    Apipie.configuration.doc_path = doc_path
    Apipie.configuration.swagger_suppress_warnings = true
    allow(Apipie).to receive(:reload_documentation)
    subject.invoke(*task_args)
  end

  describe 'static swagger specification files' do

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
      JSON.parse(apidoc_swagger_json)
    end

    let(:doc_output) do
      File.join(::Rails.root, doc_path, 'apidoc')
    end

    let(:ref_output) do
      File.join(::Rails.root, doc_path, 'apidoc_ref')
    end


    def expect_param_def(http_method, path, param_name, field_path, value)
      params = apidoc_swagger["paths"][path][http_method]["parameters"]
      param = params.select { |p| p if p["name"] == param_name }[0]
      expect(param&.dig(*Array.wrap(field_path))).to eq(value)
    end

    def expect_tags_def(http_method, path, value)
      params = apidoc_swagger["paths"][path][http_method]["tags"]
      expect(params).to eq(value)
    end

    def body_param_def(http_method, path, param_name)
      request_body = apidoc_swagger.dig("paths", path, http_method, "requestBody", "content")
      body = request_body.values.first
      schema_properties = body["schema"]["properties"]
      # print JSON.pretty_generate(schema_properties)
      param = (schema_properties.select {|k,v| v if k == param_name })[param_name]
      # print JSON.pretty_generate(param)
      param
    end

    def expect_body_param_def(http_method, path, param_name, field, value)
      param = body_param_def(http_method, path, param_name)
      expect(param[field]).to eq(value)
    end


    describe 'apipie:static_swagger_json[development,json,_tmp]' do
      it "generates static swagger files for the default version of apipie docs" do
        # print apidoc_swagger_json

        expect(apidoc_swagger["info"]["title"]).to eq("Test app (params in:body)")
        expect(apidoc_swagger["info"]["version"]).to eq("#{Apipie.configuration.default_version}")
      end

      it "includes expected values in the generated swagger file" do
        expect_param_def("get", "/twitter_example/{id}", "screen_name", "in", "query")
        expect_param_def("put", "/users/{id}", "id", "in", "path")
        expect_body_param_def("put", "/users/{id}", "oauth", "type", "string")
        expect_body_param_def("put", "/users/{id}", "user", "type", "object")

        user = body_param_def("put", "/users/{id}", "user")
        expect(user["properties"]["name"]["type"]).to eq("string")

        expect_param_def("get", "/users/by_department", "department", "in", "query")
        expect_param_def("get", "/users/by_department", "department", %w[schema enum],
                         %w[finance operations sales marketing HR])

        expect_tags_def("get", "/twitter_example/{id}/followers", %w[twitter_example following index search])
      end

      it "generates a valid swagger file" do
        # print apidoc_swagger_json
        expect(apidoc_swagger_json).to match_json_schema(swagger_schema)
      end
    end

    describe 'apipie:static_swagger_json[development,form_data,_tmp]' do
      it "generates static swagger files for the default version of apipie docs" do
        # print apidoc_swagger_json

        expect(apidoc_swagger["info"]["title"]).to eq("Test app (params in:formData)")
        expect(apidoc_swagger["info"]["version"]).to eq("#{Apipie.configuration.default_version}")

      end

      it "includes expected values in the generated swagger file" do
        expect_param_def("get", "/twitter_example/{id}", "screen_name", "in", "query")
        expect_param_def("put", "/users/{id}", "id", "in", "path")
        expect_param_def("get", "/users/by_department", "department", "in", "query")
        expect_param_def("get", "/users/by_department", "department", %w[schema enum],
                         %w[finance operations sales marketing HR])

        expect_body_param_def("put", "/users/{id}", "oauth", "type", "string")

        expect_tags_def("get", "/twitter_example/{id}/followers", %w[twitter_example following index search])

      end

      it "generates a valid swagger file" do
        # print apidoc_swagger_json
        expect(apidoc_swagger_json).to match_json_schema(swagger_schema)
      end
    end

    describe 'apipie:did_swagger_change[development,form_data,_tmp]' do
      it "keeps a reference file" do
        expect(Pathname(ref_output).children.count).to eq(2)  # one file for each language
      end
    end
  end

end
