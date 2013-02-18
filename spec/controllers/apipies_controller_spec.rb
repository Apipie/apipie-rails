require 'spec_helper'
require 'fileutils'

describe Apipie::ApipiesController do

  describe "GET index" do

    it "test if route exists" do
      get :index

      assert_response :success
    end

  end

  describe "reload_controllers" do

    RSpec::Matchers.define :reload_documentation do
      match do
        Apipie.should_receive(:reload_documentation)
        get :index
        begin
          RSpec::Mocks.verify
        rescue RSpec::Mocks::MockExpectationError
          false
        end
      end

      failure_message_for_should { "the documentation expected to be reloaded but it was not" }
      failure_message_for_should_not { "the documentation expected not to be reloaded but it was" }
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
          Rails.stub(:env => mock(:development? => true))
        end
        it { should reload_documentation }
      end

      context "and it's not development environment" do
        it { should_not reload_documentation }
      end
    end


    context "it's explicitly enabled" do
      before do
        Apipie.configuration.reload_controllers = true
      end

      context "and it's in development environment" do
        before do
          Rails.stub(:env => mock(:development? => true))
        end
        it { should reload_documentation }
      end

      context "and it's not development environment" do
        it { should reload_documentation }
      end
    end

    context "it's explicitly enabled" do
      before do
        Apipie.configuration.reload_controllers = false
      end

      context "and it's in development environment" do
        before do
          Rails.stub(:env => mock(:development? => true))
        end
        it { should_not reload_documentation }
      end

      context "and it's not development environment" do
        it { should_not reload_documentation }
      end
    end

    context "api_controllers_matcher is specified" do
      before do
        Apipie.configuration.reload_controllers = true
        Apipie.configuration.api_controllers_matcher = nil
      end

      it { should_not reload_documentation }
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
      Apipie.configuration.cache_dir = cache_dir
      @orig_version = Apipie.configuration.default_version
      Apipie.configuration.default_version = 'v1'
    end

    after do
      Apipie.configuration.use_cache = false
      Apipie.configuration.default_version = @orig_version
      # FileUtils.rm_r(cache_dir) if File.exists?(cache_dir)
    end

    it "uses the file in cache dir instead of generating the content on runtime" do
      get :index
      response.body.should == "apidoc.html cache v1"
      get :index, :version => 'v1'
      response.body.should == "apidoc.html cache v1"
      get :index, :version => 'v2'
      response.body.should == "apidoc.html cache v2"
      get :index, :version => 'v1', :format => "html"
      response.body.should == "apidoc.html cache v1"
      get :index, :version => 'v1', :format => "json"
      response.body.should == "apidoc.json cache"
      get :index, :version => 'v1', :format => "html", :resource => "resource"
      response.body.should == "resource.html cache"
      get :index, :version => 'v1', :format => "html", :resource => "resource", :method => "method"
      response.body.should == "method.html cache"
    end

  end
end
