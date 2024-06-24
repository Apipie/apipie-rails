require 'spec_helper'

describe Apipie::Generator::Swagger::ParamDescription::Builder do
  let(:validator) { String }
  let(:validator_options) { {} }
  let(:path) { '/api' }
  let(:http_method) { :GET }
  let(:in_schema) { true }
  let(:builder) do
    described_class.new(
      param_description,
      in_schema: in_schema,
      controller_method: method_desc
    )
  end
  let(:generated_block) { builder.to_swagger }
  let(:base_param_description_options) { {} }

  let(:param_description_options) do
    base_param_description_options.merge(validator_options)
  end

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

  let(:param_description) do
    Apipie::ParamDescription.new(
      method_desc,
      :param,
      validator,
      param_description_options
    )
  end

  describe 'required' do
    subject { generated_block[:required] }

    it { is_expected.to be_blank }

    context 'when is required' do
      let(:base_param_description_options) { { required: true } }

      it { is_expected.to eq(true) }
    end

    context 'when in_schema is false' do
      let(:in_schema) { false }

      it { is_expected.to be_blank }

      context 'and is required' do
        let(:base_param_description_options) { { required: true } }

        it { is_expected.to eq(true) }
      end
    end
  end

  describe 'warning' do
    before { Singleton.__init__(Apipie::Generator::Swagger::WarningWriter) }

    subject { generated_block }

    context 'when required is true' do
      let(:base_param_description_options) { { required: true } }

      it 'does not output an option without default warning' do
        expect { subject }.not_to output(
          /is optional but default value is not specified/
        ).to_stderr
      end
    end

    context 'when required is false' do
      context 'when default_value is nil' do
        let(:base_param_description_options) do
          { required: false, default_value: nil }
        end

        it 'does not warn' do
          expect { subject }.not_to output(
            /is optional but default value is not specified/
          ).to_stderr
        end
      end

      context 'when default_value is 123' do
        let(:base_param_description_options) do
          { required: false, default_value: 123 }
        end

        it 'does not warn' do
          expect { subject }.not_to output(
            /is optional but default value is not specified/
          ).to_stderr
        end
      end

      context 'default_value not given' do
        let(:base_param_description_options) { { required: false } }

        it 'warns' do
          expect { subject }.to output(
            /is optional but default value is not specified/
          ).to_stderr
        end

        context 'and param is a prop desc with a delegated controller method' do
          let(:param_description) do
            Apipie.prop(:param, 'object', param_description_options, [])
          end

          let(:method_desc) do
            Apipie::Generator::Swagger::MethodDescription::Decorator.new(
              Apipie::MethodDescription.new(:show, resource_desc, dsl_data)
            )
          end

          it 'warns' do
            expect { subject }.to output(
              /is optional but default value is not specified/
            ).to_stderr
          end
        end
      end
    end
  end

  describe '.with_type' do
    subject { generated_block[:type] }

    it { is_expected.to be_blank }

    context 'when type is assigned' do
      before { builder.with_type(with_null: false ) }

      it { is_expected.to be_present }
    end
  end

  describe '.with_description' do
    subject { generated_block[:description] }

    it { is_expected.to be_blank }

    context 'when description is assigned' do
      let(:param_description_options) { { desc: 'some-description' } }

      before { builder.with_description(language: 'en') }

      it { is_expected.to be_present }
    end
  end

  describe '.with_name' do
    subject { generated_block[:name] }

    it { is_expected.to be_blank }

    context 'when name is assigned' do
      before { builder.with_name }

      it { is_expected.to be_present }
    end
  end

  describe '.with_in' do
    subject { generated_block[:in] }

    it { is_expected.to be_blank }

    context 'when in is assigned' do
      let(:in_schema) { false }

      before { builder.with_in(http_method: 'get') }

      it { is_expected.to be_present }
    end
  end

  describe 'example' do
    subject { generated_block[:example] }

    it { is_expected.to be_blank }

    context 'when example is assigned' do
      let(:base_param_description_options) { { example: 'example' } }

      it { is_expected.to eq('example') }
    end
  end
end
