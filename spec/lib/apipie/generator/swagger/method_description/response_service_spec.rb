require 'spec_helper'

describe Apipie::Generator::Swagger::MethodDescription::ResponseService do
  let(:http_method) { nil }
  let(:language) { :en }
  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  let(:method_description) do
    Apipie::Generator::Swagger::MethodDescription::Decorator.new(
      Apipie::MethodDescription.new(
        'create',
        Apipie::ResourceDescription.new(ApplicationController, 'pets'),
        dsl_data
      )
    )
  end

  let(:returns) { [] }

  let(:service) do
    described_class.new(
      method_description,
      http_method: http_method,
      language: language
    )
  end

  describe '#call' do
    describe 'headers' do
      subject(:headers) { service.call[status_code][:headers] }

      let(:status_code) { 200 }

      it { is_expected.to be_blank }

      context 'when headers exists' do
        let(:dsl_data) { super().merge({ returns: returns }) }
        let(:returns) { { status_code => [{}, nil, returns_dsl, nil] } }

        let(:returns_dsl) do
          proc do
            header 'link', String, 'Relative links'
            header 'Current-Page', Integer, 'The current page'
          end
        end

        it 'returns the correct format headers' do
          expect(headers).to eq({
                                  'link' => {
                                    description: 'Relative links',
                                    type: 'string'
                                  },
                                  'Current-Page' => {
                                    description: 'The current page',
                                    type: 'integer'
                                  }
                                })
        end
      end
    end
  end
end
