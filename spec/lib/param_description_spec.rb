require "spec_helper"

describe Apipie::ParamDescription do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  let(:resource_desc) do
    Apipie::ResourceDescription.new(UsersController, "users")
  end

  let(:method_desc) do
    Apipie::MethodDescription.new(:show, resource_desc, dsl_data)
  end

  describe "validator selection" do

    it "should allow nil validator" do
      param = Apipie::ParamDescription.new(method_desc, :hidden_param, nil)
      param.validator.should be_nil
    end

    it "should throw exception on unknown validator" do
      proc { Apipie::ParamDescription.new(method_desc, :param, :unknown) }.should raise_error(RuntimeError, /Validator.*not found/)
    end

    it "should pick type validator" do
      Apipie::Validator::BaseValidator.should_receive(:find).and_return(:validator_instance)
      param = Apipie::ParamDescription.new(method_desc, :param, String)
      param.validator.should == :validator_instance
    end

  end

  describe "concern substitution" do

    let(:concern_dsl_data) { dsl_data.merge(:from_concern => true) }

    let(:concern_resource_desc) do
      Apipie::ResourceDescription.new(ConcernsController, "concerns")
    end

    let(:concern_method_desc) do
      Apipie::MethodDescription.new(:show, concern_resource_desc, concern_dsl_data)
    end

    it "should replace string parameter name with colon prefix" do
      param = Apipie::ParamDescription.new(concern_method_desc, ":string_subst", String)
      param.name.should == "string"
    end

    it "should replace symbol parameter name" do
      param = Apipie::ParamDescription.new(concern_method_desc, :concern, String)
      param.name.should == :user
    end

    it "should keep original value for strings without colon prefixes" do
      param = Apipie::ParamDescription.new(concern_method_desc, "string_subst", String)
      param.name.should == "string_subst"
    end

    it "should keep the original value when a string can't be replaced" do
      param = Apipie::ParamDescription.new(concern_method_desc, ":param", String)
      param.name.should == ":param"
    end

    it "should keep the original value when a symbol can't be replaced" do
      param = Apipie::ParamDescription.new(concern_method_desc, :param, String)
      param.name.should == :param
    end
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

  describe "required params in action aware validator" do

    subject { method_description.params[:user].validator.hash_params_ordered }

    let(:required) do
      subject.find_all(&:required).map(&:name)
    end

    let(:allowed_nil) do
      subject.find_all(&:allow_nil).map(&:name)
    end

    context "with resource creation" do

      let(:method_description) do
        Apipie.get_method_description(UsersController, :create)
      end

      it "makes the param required" do
        required.should include :name
        required.should include :pass
      end

      it "doesn't allow nil" do
        allowed_nil.should_not include :name
        allowed_nil.should_not include :pass
      end
    end

    context "with resource update" do

      let(:method_description) do
        Apipie.get_method_description(UsersController, :update)
      end

      it "doesn't make the param required" do
        required.should_not include :name
        required.should_not include :pass
      end

      it "doesn't allow nil" do
        allowed_nil.should_not include :name
        allowed_nil.should_not include :pass
      end

      it "doesn't touch params with explicitly set allow_nil" do
        allowed_nil.should_not include :membership
      end
    end

    context "with explicitly setting action type in param group" do
      let(:method_description) do
        Apipie.get_method_description(UsersController, :admin_create)
      end

      it "makes the param required" do
        required.should include :name
        required.should include :pass
      end

      it "doesn't allow nil" do
        allowed_nil.should_not include :name
        allowed_nil.should_not include :pass
      end
    end
  end
end
