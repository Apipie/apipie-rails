require "spec_helper"

describe Apipie::ParamDescription do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  let(:resource_desc) do
    Apipie::ResourceDescription.new(UsersController, "users")
  end

  let(:method_desc) do
    Apipie::MethodDescription.new(:show, resource_desc, nil, dsl_data)
  end


  describe "required_by_default config option" do
    context "parameters required by default" do

      before { Apipie.configuration.required_by_default = true }

      it "should set param as required by default" do
        param = Apipie::ParamDescription.new(method_desc, :required_by_default, String)
        param.required.should be_true
      end

      it "should be possible to set param as optional" do
        param = Apipie::ParamDescription.new(method_desc, :optional, String, :required => false)
        param.required.should be_false
      end

    end

    context "parameters optional by default" do

      before { Apipie.configuration.required_by_default = false }

      it "should set param as optional by default" do
        param = Apipie::ParamDescription.new(method_desc, :optional_by_default, String)
        param.required.should be_false
      end

      it "should be possible to set param as required" do
        param = Apipie::ParamDescription.new(method_desc, :required, String, 'description','required' => true)
        param.required.should be_true
      end

    end

  end

end
