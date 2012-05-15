require 'spec_helper'

describe Restapi::RestapisController do

  describe "GET index" do

    it "test if route exists" do
      get :index

      assert_response :success
    end

  end

  describe "reload_controllers" do

    RSpec::Matchers.define :reload_documentation do
      match do
        begin
          orig = Restapi.get_resource_description("users")._short_description.dup
          Restapi.get_resource_description("users")._short_description << 'Modified'
          get :index
          ret = Restapi.get_resource_description("users")._short_description == orig
        ensure
          Restapi.get_resource_description("users")._short_description.gsub!('Modified', "")
        end
      end

      failure_message_for_should { "the documentation expected to be reloaded but it was not" }
      failure_message_for_should_not { "the documentation expected not to be reloaded but it was" }
    end

    before do
      Restapi.configuration.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "**","*.rb")
      if Restapi.configuration.send :instance_variable_defined?, "@reload_controllers"
        Restapi.configuration.send :remove_instance_variable, "@reload_controllers"
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
        Restapi.configuration.reload_controllers = true
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
        Restapi.configuration.reload_controllers = false
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
        Restapi.configuration.reload_controllers = true
        Restapi.configuration.api_controllers_matcher = nil
      end

      it { should_not reload_documentation }
    end
  end
end
