require 'spec_helper'

describe Apipie::Generator::Swagger::ParamDescription::Type do
  let(:validator_options) { {} }
  let(:param_description_options) { {}.merge(validator_options) }
  let(:http_method) { :GET }
  let(:path) { '/api' }
  let(:validator) { String }

  let(:base_dsl_data) do
    {
      :api => false,
      :api_args => [],
      :api_from_routes => nil,
      :errors => [],
      :tag_list => [],
      :returns => {},
      :params => [],
      :headers => [],
      :resource_id => nil,
      :short_description => nil,
      :description => nil,
      :examples => [],
      :see => [],
      :formats => nil,
      :api_versions => [],
      :meta => nil,
      :show => true,
      :deprecated => false
    }
  end

  let(:dsl_data) do
    base_dsl_data.merge({
      api_args: [
        [
          http_method,
          path,
          'description',
          { deprecated: true }
        ]
      ]
    })
  end

  let(:resource_desc) do
    Apipie::ResourceDescription.new(UsersController, 'dummy')
  end

  let(:method_desc) do
    Apipie::MethodDescription.new(:show, resource_desc, dsl_data)
  end

  let(:param_description_name) { 'some_param' }

  let(:param_description) do
    Apipie::ParamDescription.new(
      method_desc,
      param_description_name,
      validator,
      param_description_options
    )
  end

  let(:controller_method) { 'index' }

  let(:type_definition) do
    described_class.
      new(param_description, with_null: false, controller_method: controller_method).
      to_hash
  end

  describe 'type' do
    subject { type_definition[:type] }

    it { is_expected.to eq(validator.to_s.downcase) }

    context 'when validator is enum' do
      let(:validator) { %w[name enum] }

      it { is_expected.to eq('string') }
    end

    context 'when validator is a Hash' do
      let(:validator) { Hash }

      it { is_expected.to eq('object') }
    end
  end

  describe 'items' do
    let(:items) { type_definition[:items] }

    subject { items }

    context 'when has validator is Array' do
      let(:validator) { Array }

      it { is_expected.to eq({ type: 'string' }) }

      context 'of Hash' do
        let(:validator_options) { { of: Hash } }

        let(:reference) do
          Apipie::Generator::Swagger::OperationId.
            new(http_method: http_method, path: path, param: param_description_name).
            to_s
        end

        it { is_expected.to eq({ type: 'string' }) }

        context 'and swagger.json_input_uses_refs is set to true' do
          before { Apipie.configuration.generator.swagger.json_input_uses_refs = true }
          after { Apipie.configuration.generator.swagger.json_input_uses_refs = false }

          it 'returns the reference' do
            expect(subject).to eq({ '$ref' => reference })
          end
        end
      end

      context 'of a Swagger type' do
        let(:validator_options) { { of: Integer } }

        it { is_expected.to eq({ type: 'integer' }) }
      end

      describe 'enum' do
        subject { items[:enum] }

        it { is_expected.to be_blank }

        context 'when validator is Array' do
          let(:validator) { Array }

          it { is_expected.to be_blank }

          context 'and an array of in values is given' do
            let(:enum_values) { %w[enum-value-1 enum-value-2] }
            let(:validator_options) { { in: %w[enum-value-1 enum-value-2] } }

            it { is_expected.to eq(enum_values) }
          end
        end
      end
    end
  end

  describe 'enum' do
    subject { type_definition[:enum] }

    context 'and an array of in values is given' do
      let(:validator) { %w[enum-value-1 enum-value-2] }

      it { is_expected.to eq(validator) }
    end
  end

  describe 'additionalProperties' do
    subject { type_definition[:additionalProperties] }

    it  { is_expected.to be_blank }

    context 'when validator is a Hash' do
      let(:validator) { Hash }

      it { is_expected.to be_truthy }
    end
  end

  describe 'warnings' do
    before { Singleton.__init__(Apipie::Generator::Swagger::WarningWriter) }

    subject { type_definition }

    context 'when validator is a Hash' do
      let(:validator) { Hash }

      it 'outputs a hash without internal typespec warning' do
        expect { subject }.to output(/is a generic Hash without an internal type specification/).to_stderr
      end

      context 'and param is a prop desc with a delegated controller method' do
        let(:param_description) do
          Apipie.prop(param_description_name, 'object', {}, [])
        end

        let(:controller_method) do
          Apipie::Generator::Swagger::MethodDescription::Decorator.new(
            method_desc
          )
        end

        it 'outputs a hash without internal typespec warning' do
          expect { subject }.to output(/is a generic Hash without an internal type specification/).to_stderr
        end
      end
    end
  end
end
