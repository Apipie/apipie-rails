require 'spec_helper'

describe Apipie::ResponseDescription do
  let(:resource_description) do
    Apipie::ResourceDescription.new(PetsController, 'pets')
  end

  let(:method_description) do
    Apipie::MethodDescription.new(
      'create',
      resource_description,
      ActionController::Base.send(:_apipie_dsl_data_init)
    )
  end

  let(:response_description_dsl) { proc {} }
  let(:options) { {} }

  let(:response_description) do
    described_class.new(
      method_description,
      204,
      options,
      PetsController,
      response_description_dsl,
      nil
    )
  end

  describe '#to_json' do
    let(:to_json) { response_description.to_json }

    describe 'headers' do
      subject(:headers) { to_json[:headers] }

      it { is_expected.to be_blank }

      context 'when response has headers' do
        let(:response_description_dsl) do
          proc do
            header 'Current-Page', Integer, 'The current page in the pagination', required: true
          end
        end

        it 'returns the header' do
          expect(headers).to contain_exactly({
                                               name: 'Current-Page',
                                               description: 'The current page in the pagination',
                                               validator: 'integer',
                                               options: { required: true }
                                             })
        end
      end
    end
  end
end
