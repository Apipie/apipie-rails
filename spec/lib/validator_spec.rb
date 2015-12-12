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
        expect(validator.expected_type).to eq('hash')
      end

      it "should return array for type Array" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Array)
        expect(validator.expected_type).to eq('array')
      end

      it "should return numeric for type Numeric" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Numeric)
        expect(validator.expected_type).to eq('numeric')
      end

      it "should return string by default" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Symbol)
        expect(validator.expected_type).to eq('string')
      end

    end

  end

  describe 'ArrayClassValidator' do
    it "should validate by object class" do
      validator = Apipie::Validator::ArrayClassValidator.new(params_desc, [Fixnum, String])
      expect(validator.validate("1")).to be_truthy
      expect(validator.validate(1)).to be_truthy
      expect(validator.validate({ 1 => 1 })).to be_falsey
    end
  end
end
