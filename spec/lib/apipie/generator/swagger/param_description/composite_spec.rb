require 'spec_helper'

describe Apipie::Generator::Swagger::ParamDescription::Composite do
  let(:param_descriptions) {}

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  let(:resource_desc) do
    Apipie::ResourceDescription.new(UsersController, "users")
  end

  let(:context) do
    Apipie::Generator::Swagger::Context.new(
      allow_null: true,
      http_method: 'get',
      controller_method: method_description
    )
  end

  let(:method_description) do
    Apipie::MethodDescription.new(:create, resource_desc, dsl_data)
  end

  let(:composite) { described_class.new(param_descriptions, context) }

  let(:swagger) { composite.to_swagger }

  let(:params_description_one) do
    Apipie::ParamDescription.new(method_description, :some_param, String)
  end

  let(:params_description_two) do
    Apipie::ParamDescription.new(method_description, :some_other_param, String)
  end

  let(:param_descriptions) { [params_description_one, params_description_two] }

  context 'when no param descriptions are given' do
    let(:param_descriptions) { [] }

    subject { swagger }

    it { is_expected.to be_blank }
  end

  describe 'additionalProperties' do
    subject { swagger[:additionalProperties] }

    it { is_expected.to be_falsey }

    context 'when additional properties in response allowed' do
      before do
        Apipie.configuration.generator.swagger.allow_additional_properties_in_response = true
      end

      it { is_expected.to be_blank }
    end
  end

  xdescribe 'nested additionalProperties' do
    context 'when param description has nested params' do
      let(:validator) do

      end

      let(:params_description_one) do
        Apipie::ParamDescription.new(
          method_description,
          :some_param,
          validator,
          { required: true }
        )
      end
    end
  end

  describe 'required' do
    subject { swagger[:required] }

    it { is_expected.to be_blank }

    context 'when param description is required' do
      let(:params_description_one) do
        Apipie::ParamDescription.new(
          method_description,
          :some_param,
          String,
          { required: true }
        )
      end

      it { is_expected.to be_truthy }
    end
  end
end
