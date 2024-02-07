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

      it "returns hash for type Hash" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Hash)
        expect(validator.expected_type).to eq('hash')
      end

      it "returns array for type Array" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Array)
        expect(validator.expected_type).to eq('array')
      end

      it "returns numeric for type Numeric" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Numeric)
        expect(validator.expected_type).to eq('numeric')
      end

      it "returns string by default" do
        validator = Apipie::Validator::TypeValidator.new(params_desc, Symbol)
        expect(validator.expected_type).to eq('string')
      end

    end

    describe 'NumberValidator' do
      it 'expects a Numeric type' do
        validator = Apipie::Validator::BaseValidator.find(params_desc, :number, nil, nil)
        expect(validator.expected_type).to eq('numeric')
      end
    end
  end

  describe 'BooleanValidator' do
    let(:validator) do
      Apipie::Validator::BooleanValidator
    end

    let(:validator_instance) { validator.new(params_desc) }

    describe '.build' do
      subject { validator.build(params_desc, argument, nil, nil) }

      context 'when argument is [true, false]' do
        let(:argument) { [true, false] }

        it { is_expected.to be_an_instance_of(Apipie::Validator::BooleanValidator) }
      end

      context 'when argument is :bool' do
        let(:argument) { :bool }

        it { is_expected.to be_an_instance_of(Apipie::Validator::BooleanValidator) }
      end

      context 'when argument :boolean' do
        let(:argument) { :boolean }

        it { is_expected.to be_an_instance_of(Apipie::Validator::BooleanValidator) }
      end

      context 'when argument :booooooooolean' do
        let(:argument) { :booooooooolean }

        it { is_expected.to be_nil }
      end
    end

    describe '#validate' do
      it "validates by object class" do
        expect(validator_instance.validate("1")).to be_truthy
        expect(validator_instance.validate(1)).to be_truthy
        expect(validator_instance.validate(true)).to be_truthy
        expect(validator_instance.validate(0)).to be_truthy
        expect(validator_instance.validate(false)).to be_truthy
        expect(validator_instance.validate({ 1 => 1 })).to be_falsey
      end
    end

    describe '#description' do
      subject { validator_instance.description }

      it { is_expected.to eq('Must be one of: <code>true</code>, <code>false</code>, <code>1</code>, <code>0</code>.') }
    end
  end

  describe 'ArrayClassValidator' do
    it "validates by object class" do
      validator = Apipie::Validator::ArrayClassValidator.new(params_desc, [Integer, String])
      expect(validator.validate("1")).to be_truthy
      expect(validator.validate(1)).to be_truthy
      expect(validator.validate({ 1 => 1 })).to be_falsey
    end

    it "has a valid description" do
      validator = Apipie::Validator::ArrayClassValidator.new(params_desc, [Float, String])
      expect(validator.description).to eq('Must be one of: <code>Float</code>, <code>String</code>.')
    end
  end

  describe 'RegexpValidator' do
    it "validates by object class" do
      validator = Apipie::Validator::RegexpValidator.new(params_desc, /^valid( extra)*$/)
      expect(validator.validate("valid")).to be_truthy
      expect(validator.validate("valid extra")).to be_truthy
      expect(validator.validate("valid extra extra")).to be_truthy
      expect(validator.validate("invalid")).to be_falsey
    end

    it "has a valid description" do
      validator = Apipie::Validator::RegexpValidator.new(params_desc, /^valid( extra)*$/)
      expect(validator.description).to eq('Must match regular expression <code>/^valid( extra)*$/</code>.')
    end
  end

  describe 'EnumValidator' do
    it "validates by object class" do
      validator = Apipie::Validator::EnumValidator.new(params_desc, ['first', 'second & third'])
      expect(validator.validate("first")).to be_truthy
      expect(validator.validate("second & third")).to be_truthy
      expect(validator.validate(1)).to be_falsey
      expect(validator.validate({ 1 => 1 })).to be_falsey
    end

    it "has a valid description" do
      validator = Apipie::Validator::EnumValidator.new(params_desc, ['first', 'second & third'])
      expect(validator.description).to eq('Must be one of: <code>first</code>, <code>second &amp; third</code>.')
    end
  end
end
