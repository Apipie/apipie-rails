require 'spec_helper'

describe Apipie::Generator::Swagger::ParamDescription::Description do
  let(:param_description_options) { {} }
  let(:http_method) { :GET }
  let(:path) { '/api' }
  let(:validator) { String }
  let(:language) {}

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

  let(:description_definition) do
    described_class.new(param_description, language: language).to_hash
  end

  describe 'description' do
    subject { description_definition[:description] }

    it { is_expected.to be_blank }

    context 'when desc is given to options' do
      let(:desc) { 'Some description' }
      let(:param_description_options) { { desc: desc } }

      it { is_expected.to eq(desc) }
    end
  end
end
