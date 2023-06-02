require 'spec_helper'

describe Apipie::Generator::Swagger::ResourceDescriptionComposite do
  let(:dsl_data) { {} }
  let(:resource_id) { 'pets' }
  let(:resource_description) do
    Apipie::ResourceDescription.new(PetsController, resource_id, dsl_data)
  end

  let(:resource_descriptions) { [resource_description] }
  let(:composite) { described_class.new(resource_descriptions, language: :en) }

  describe '#to-swagger' do
    subject { composite.to_swagger }

    it { is_expected.to include(:paths, :tags) }

    describe 'tags' do
      subject(:tag) { composite.to_swagger[:tags].first }

      it { is_expected.to be_blank }

      context 'when resource description has full description' do
        let(:dsl_data) { { description: 'something' } }

        it 'returns the name and description' do
          expect(tag).to eq(
            {
              name: resource_id,
              description: resource_description._full_description
            }
          )
        end
      end
    end
  end
end
