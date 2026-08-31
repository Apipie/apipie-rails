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

  describe 'array of nested params' do
    # `param :some_param, Array do ... end` (no `of:`/`array_of:` option)
    # builds a NestedValidator, whose own params (declared in the block)
    # should still be recursed into and rendered as the array's `items`
    # schema, not silently collapsed to `{ type: 'array', items: { type: 'string' } }`.
    let(:params_description_one) do
      Apipie::ParamDescription.new(method_description, :some_param, Array) do
        param :nested_field, String, required: true
        param :other_field, Integer
      end
    end

    let(:param_descriptions) { [params_description_one] }

    subject(:some_param_schema) { swagger[:properties][:some_param] }

    it 'renders the item schema from the nested params instead of falling back to string items' do
      expect(some_param_schema).to eq(
        type: 'array',
        items: {
          type: 'object',
          properties: {
            nested_field: { type: 'string', required: true, 'x-nullable': true },
            other_field: { type: 'number', 'x-nullable': true }
          },
          required: [:nested_field]
        },
        'x-nullable': true
      )
    end
  end

  describe 'nullability' do
    subject(:properties) { swagger[:properties] }

    let(:context) do
      Apipie::Generator::Swagger::Context.new(
        allow_null: false,
        http_method: 'get',
        controller_method: method_description
      )
    end

    it 'does not mark params as nullable by default' do
      expect(properties[:some_param][:type]).to eq('string')
    end

    context 'when a param explicitly sets allow_nil' do
      let(:params_description_one) do
        Apipie::ParamDescription.new(
          method_description,
          :some_param,
          String,
          { allow_nil: true }
        )
      end

      it 'marks only that param as nullable' do
        expect(properties[:some_param][:type]).to eq('string')
        expect(properties[:some_param][:'x-nullable']).to be(true)
        expect(properties[:some_other_param][:type]).to eq('string')
        expect(properties[:some_other_param]).not_to have_key(:'x-nullable')
      end
    end

    context 'when a nested (Hash) param explicitly sets allow_nil' do
      # Nested/composed schemas go through Composite#with_null, a separate
      # code path from the plain-scalar one above (Type#to_hash) -- it used
      # to wrap with `anyOf` instead of `x-nullable` (see with_null's own
      # comment for why), which this pins as also fixed.
      let(:params_description_one) do
        Apipie::ParamDescription.new(method_description, :some_param, Hash, { allow_nil: true }) do
          param :nested_field, String, required: true
        end
      end

      it 'marks the nested schema as nullable via x-nullable, not anyOf' do
        expect(properties[:some_param][:type]).to eq('object')
        expect(properties[:some_param][:'x-nullable']).to be(true)
        expect(properties[:some_param]).not_to have_key(:anyOf)
        expect(properties[:some_param][:properties][:nested_field]).to eq(type: 'string', required: true)
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
