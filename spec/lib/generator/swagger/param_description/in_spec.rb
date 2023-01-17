require 'spec_helper'

describe Apipie::Generator::Swagger::ParamDescription::In do
  let(:validator_options) { {} }
  let(:param_description_options) { {}.merge(validator_options) }
  let(:with_null) { false }
  let(:http_method) { :GET }
  let(:path) { '/api' }
  let(:validator) { String }
  let(:default_in_value) { 'kati' }
  let(:in_schema) { true }

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

  let(:in_definition) do
    described_class.new(
      param_description,
      default_in_value: default_in_value,
      http_method: http_method,
      in_schema: in_schema
    ).to_hash
  end

  describe 'in' do
    subject { in_definition[:in] }

    it { is_expected.to be_blank }

    context 'when in_schema is false' do
      let(:in_schema) { false }

      it { is_expected.to eq(default_in_value) }
    end
  end
end
