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

    describe 'NumberValidator' do
      it 'should expect a Numeric type' do
        validator = Apipie::Validator::BaseValidator.find(params_desc, :number, nil, nil)
        expect(validator.expected_type).to eq('numeric')
      end
    end
  end

  describe 'BooleanValidator' do
    it "should validate by object class" do
      validator = Apipie::Validator::BooleanValidator.new(params_desc)
      expect(validator.validate("1")).to be_truthy
      expect(validator.validate(1)).to be_truthy
      expect(validator.validate(true)).to be_truthy
      expect(validator.validate(0)).to be_truthy
      expect(validator.validate(false)).to be_truthy
      expect(validator.validate({ 1 => 1 })).to be_falsey
    end

    it "should have a valid description" do
      validator = Apipie::Validator::BooleanValidator.new(params_desc)
      expect(validator.description).to eq('Must be one of: <code>true</code>, <code>false</code>, <code>1</code>, <code>0</code>.')
    end
  end

  describe 'ArrayClassValidator' do
    it "should validate by object class" do
      validator = Apipie::Validator::ArrayClassValidator.new(params_desc, [Fixnum, String])
      expect(validator.validate("1")).to be_truthy
      expect(validator.validate(1)).to be_truthy
      expect(validator.validate({ 1 => 1 })).to be_falsey
    end

    it "should have a valid description" do
      validator = Apipie::Validator::ArrayClassValidator.new(params_desc, [Float, String])
      expect(validator.description).to eq('Must be one of: <code>Float</code>, <code>String</code>.')
    end
  end

  describe 'RegexpValidator' do
    it "should validate by object class" do
      validator = Apipie::Validator::RegexpValidator.new(params_desc, /^valid( extra)*$/)
      expect(validator.validate("valid")).to be_truthy
      expect(validator.validate("valid extra")).to be_truthy
      expect(validator.validate("valid extra extra")).to be_truthy
      expect(validator.validate("invalid")).to be_falsey
    end

    it "should have a valid description" do
      validator = Apipie::Validator::RegexpValidator.new(params_desc, /^valid( extra)*$/)
      expect(validator.description).to eq('Must match regular expression <code>/^valid( extra)*$/</code>.')
    end
  end

  describe 'EnumValidator' do
    it "should validate by object class" do
      validator = Apipie::Validator::EnumValidator.new(params_desc, ['first', 'second & third'])
      expect(validator.validate("first")).to be_truthy
      expect(validator.validate("second & third")).to be_truthy
      expect(validator.validate(1)).to be_falsey
      expect(validator.validate({ 1 => 1 })).to be_falsey
    end

    it "should have a valid description" do
      validator = Apipie::Validator::EnumValidator.new(params_desc, ['first', 'second & third'])
      expect(validator.description).to eq('Must be one of: <code>first</code>, <code>second &amp; third</code>.')
    end
  end
end
