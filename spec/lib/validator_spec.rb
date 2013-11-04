require "spec_helper"

describe Apipie::Validator do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  let(:resource_desc) do
    Apipie::ResourceDescription.new(UsersController, "users")
  end

  let(:method_desc) do
    Apipie::MethodDescription.new(:show, resource_desc, dsl_data)
  end

  let(:params_desc) do
    Apipie::ParamDescription.new(method_desc, :param, nil)
  end

  describe 'TypeValidator' do

    context "expected type" do

      it "should return hash for type Hash" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Hash)
        validator.expected_type.should == 'hash'
      end

      it "should return array for type Array" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Array)
        validator.expected_type.should == 'array'
      end

      it "should return numeric for type Numeric" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Numeric)
        validator.expected_type.should == 'numeric'
      end

      it "should return string by default" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Symbol)
        validator.expected_type.should == 'string'
      end

    end

  end

  describe 'ArrayClassValidator' do
    it "should validate by object class" do
      validator = Apipie::Validator::ArrayClassValidator.new(params_desc, [Fixnum, String])
      validator.validate("1").should be_true
      validator.validate(1).should be_true
      validator.validate({ 1 => 1 }).should be_false
    end
  end
end
