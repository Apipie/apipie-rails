require 'spec_helper'
require 'fileutils'
require "json-schema"

describe Apipie::ApipiesController do

  describe "GET index" do

    it "succeeds on index" do
      get :index

      assert_response :success
    end

    it "succeeds on version details" do
      get :index, :params => { :version => "2.0" }

      assert_response :success
    end

    it "returns not_found on wrong version" do
      get :index, :params => { :version => "wrong_version" }

      assert_response :not_found
    end

    it "succeeds on resource details" do
      get :index, :params => { :version => "2.0", :resource => "architectures" }

      assert_response :success
    end

    it "returns not_found on wrong resource" do
      get :index, :params => { :version => "2.0", :resource => "wrong_resource" }

      assert_response :not_found
    end

    it "succeeds on method details" do
      get :index, :params => { :version => "2.0", :resource => "architectures", :method => "index" }

      assert_response :success
    end

    it "returns not_found on wrong method" do
      get :index, :params => { :version => "2.0", :resource => "architectures", :method => "wrong_method" }

      assert_response :not_found
    end
  end

  describe "reload_controllers" do

    RSpec::Matchers.define :reload_documentation do
      match do |actual|
        expect(Apipie).to receive(:reload_documentation)
        get :index
      end

      match_when_negated do |actual|
        expect(Apipie).not_to receive(:reload_documentation)
        get :index
      end

      failure_message { "the documentation expected to be reloaded but it was not" }
      failure_message_when_negated { "the documentation expected not to be reloaded but it was" }
    end

    before do
      Apipie.configuration.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "**","*.rb")
      if Apipie.configuration.send :instance_variable_defined?, "@reload_controllers"
        Apipie.configuration.send :remove_instance_variable, "@reload_controllers"
      end
    end

    context "it's not specified explicitly" do
      context "and it's in development environment" do
        before do
          allow(Rails).to receive_messages(:env => double(:development? => true))
        end
        it { is_expected.to reload_documentation }
      end

      context "and it's not development environment" do
        it { is_expected.not_to reload_documentation }
      end
    end


    context "it's explicitly enabled" do
      before do
        Apipie.configuration.reload_controllers = true
      end

      context "and it's in development environment" do
        before do
          allow(Rails).to receive_messages(:env => double(:development? => true))
        end
        it { is_expected.to reload_documentation }
      end

      context "and it's not development environment" do
        it { is_expected.to reload_documentation }
      end
    end

    context "it's explicitly enabled" do
      before do
        Apipie.configuration.reload_controllers = false
      end

      context "and it's in development environment" do
        before do
          allow(Rails).to receive_messages(:env => double(:development? => true))
        end
        it { is_expected.not_to reload_documentation }
      end

      context "and it's not development environment" do
        it { is_expected.not_to reload_documentation }
      end
    end

    context "api_controllers_matcher is specified" do
      before do
        Apipie.configuration.reload_controllers = true
        Apipie.configuration.api_controllers_matcher = nil
      end

      it { is_expected.not_to reload_documentation }
    end
  end

  describe "GET index as swagger" do

    let(:swagger_schema) do
      File.read(File.join(File.dirname(__FILE__),"../lib/swagger/openapi_2_0_schema.json"))
    end

    it "outputs swagger when format is json and type is swagger" do
      get :index, :params => { :format => "json", :type => "swagger"}

      assert_response :success
      expect(response.body).to match(/"swagger":"2.0"/)
      # puts response.body

      expect(JSON::Validator.validate(swagger_schema, response.body)).to be_truthy
    end

    it "does not output swagger when format is not json even if type is swagger" do
      get :index, :params => { :type => "swagger"}

      assert_response :success
      expect(response.body).not_to match(/"swagger":"2.0"/)
    end

    it "does not output swagger when format is json even but type is not swagger" do
      get :index, :params => { :format => "json"}

      assert_response :success
      expect(response.body).not_to match(/"swagger":"2.0"/)
    end
  end


  describe "authenticate user" do
    it "authenticate user if an authentication method is setted" do
      test = false
      Apipie.configuration.authenticate = Proc.new do
        test = true
      end
      get :index
      expect(test).to eq(true)
    end
  end

  describe "authorize document" do
    it "if an authroize method is set" do
      test = false
      Apipie.configuration.authorize = Proc.new do |controller, method, doc|
        test = true
        true
      end
      get :index
      expect(test).to eq(true)
    end
    it "remove all resources" do
      Apipie.configuration.authorize = Proc.new do |&args|
        false
      end
      get :index
      expect(assigns(:doc)[:resources]).to eq({})
    end
    it "remove all methods" do
      Apipie.configuration.authorize = Proc.new do |controller, method, doc|
        !method
      end
      get :index
      expect(assigns(:doc)[:resources]["concern_resources"][:methods]).to eq([])
      expect(assigns(:doc)[:resources]["twitter_example"][:methods]).to eq([])
      expect(assigns(:doc)[:resources]["users"][:methods]).to eq([])
    end
    it "remove specific method" do
      Apipie.configuration.authorize = nil
      get :index

      users_methods = assigns(:doc)[:resources]["users"][:methods].size
      twitter_example_methods = assigns(:doc)[:resources]["twitter_example"][:methods].size

      Apipie.configuration.authorize = Proc.new do |controller, method, doc|
        controller == "users" ? method != "index" : true
      end

      get :index

      expect(assigns(:doc)[:resources]["users"][:methods].size).to eq(users_methods - 1)
      expect(assigns(:doc)[:resources]["twitter_example"][:methods].size).to eq(twitter_example_methods)
    end
    it "does not allow access to swagger when authorization is set" do
      get :index, :params => { :format => "json", :type => "swagger"}

      assert_response :forbidden
    end
  end

  describe "documentation cache" do

    let(:cache_dir) { File.join(Rails.root, "tmp", "apipie-cache") }

    before do
      FileUtils.rm_r(cache_dir) if File.exists?(cache_dir)
      FileUtils.mkdir_p(File.join(cache_dir, "apidoc", "v1", "resource"))
      File.open(File.join(cache_dir, "apidoc", "v1.html"), "w") { |f| f << "apidoc.html cache v1" }
      File.open(File.join(cache_dir, "apidoc", "v2.html"), "w") { |f| f << "apidoc.html cache v2" }
      File.open(File.join(cache_dir, "apidoc", "v1.json"), "w") { |f| f << "apidoc.json cache" }
      File.open(File.join(cache_dir, "apidoc", "v1", "resource.html"), "w") { |f| f << "resource.html cache" }
      File.open(File.join(cache_dir, "apidoc", "v1", "resource", "method.html"), "w") { |f| f << "method.html cache" }

      Apipie.configuration.use_cache = true
      @orig_cache_dir = Apipie.configuration.cache_dir
      Apipie.configuration.cache_dir = cache_dir
      @orig_version = Apipie.configuration.default_version
      Apipie.configuration.default_version = 'v1'
    end

    after do
      Apipie.configuration.use_cache = false
      Apipie.configuration.default_version = @orig_version
      Apipie.configuration.cache_dir = @orig_cache_dir
      # FileUtils.rm_r(cache_dir) if File.exists?(cache_dir)
    end

    it "uses the file in cache dir instead of generating the content on runtime" do
      get :index
      expect(response.body).to eq("apidoc.html cache v1")
      get :index, :params => { :version => 'v1' }
      expect(response.body).to eq("apidoc.html cache v1")
      get :index, :params => { :version => 'v2' }
      expect(response.body).to eq("apidoc.html cache v2")
      get :index, :params => { :version => 'v1', :format => "html" }
      expect(response.body).to eq("apidoc.html cache v1")
      get :index, :params => { :version => 'v1', :format => "json" }
      expect(response.body).to eq("apidoc.json cache")
      get :index, :params => { :version => 'v1', :format => "html", :resource => "resource" }
      expect(response.body).to eq("resource.html cache")
      get :index, :params => { :version => 'v1', :format => "html", :resource => "resource", :method => "method" }
      expect(response.body).to eq("method.html cache")
    end

  end


end
