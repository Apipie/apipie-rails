require 'spec_helper'

describe Apipie::Generator::Swagger::ParamDescription::Name do
  let(:validator_options) { {} }
  let(:param_description_options) { {}.merge(validator_options) }
  let(:with_null) { false }
  let(:http_method) { :GET }
  let(:path) { '/api' }
  let(:validator) { String }
  let(:prefixed_by) {}

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

  let(:name_definition) do
    described_class.new(
      param_description,
      prefixed_by: prefixed_by
    ).to_hash
  end

  subject { name_definition[:name] }

  it { is_expected.to eq(param_description.name) }

  context 'when prefixed by is given' do
    let(:prefixed_by) { 'some-prefix' }

    it { is_expected.to eq("#{prefixed_by}[#{param_description.name}]") }
  end
end
