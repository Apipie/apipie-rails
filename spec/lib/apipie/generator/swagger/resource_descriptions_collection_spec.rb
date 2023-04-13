require 'spec_helper'

describe Apipie::Generator::Swagger::ResourceDescriptionsCollection do
  let(:collection) { described_class.new(resource_descriptions) }

  let(:users_resource_description) do
    Apipie.get_resource_description(UsersController, Apipie.configuration.default_version)
  end

  let(:pets_resource_description) do
    Apipie.get_resource_description(PetsController, Apipie.configuration.default_version)
  end

  let(:resource_descriptions) do
    {
      'development' => {
        users_resource_description._id => users_resource_description,
        pets_resource_description._id => pets_resource_description
      },
      'production' => {
        pets_resource_description._id => pets_resource_description
      }
    }
  end

  describe '#filter' do
    subject(:filtered_resource_descriptions) do
      collection.filter(
        version: version,
        resource_id: resource_id,
        method_name: method_name
      )
    end

    let(:version) { 'development' }
    let(:resource_id) { users_resource_description._id }
    let(:method_name) { nil }

    it 'filters resources for the given version and resource name' do
      expect(filtered_resource_descriptions).to eq([users_resource_description])
    end

    context 'when method name is given' do
      context 'when does not exist in the controller' do
        let(:method_name) { :i_do_not_exist }

        it { is_expected.to be_empty }
      end

      context 'when exists in the controller' do
        let(:method_name) { :show }

        it { is_expected.to eq([users_resource_description]) }
      end
    end
  end
end
