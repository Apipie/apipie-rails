require 'spec_helper'

describe Apipie::MethodDescription::ApisService do
  let(:resource) {}
  let(:controller_action) {}
  let(:api_args) { [] }
  let(:dsl) { { api_args: api_args } }
  let(:service) { described_class.new(resource, controller_action, dsl) }

  describe '#call' do
    subject { service.call }

    it { is_expected.to eq(api_args) }

    context 'when api_from_routes is given' do
      let(:controller) { UsersController }
      let(:controller_action) { :show }
      let(:resource) { Apipie::ResourceDescription.new(controller, 'dummy') }
      let(:short_description) { 'Short description' }

      let(:dsl) do
        super().merge({
          api_from_routes: {
            desc: short_description,
            options: {}
          }
        })
      end

      it 'returns an array of Apipie::MethodDescription::Api' do
        expect(subject).to all(be_an_instance_of(Apipie::MethodDescription::Api))
        expect(subject.count).to eq(1)
      end

      context 'Apipie::MethodDescription::Api' do
        subject { service.call.first }

        it 'has the correct values' do
          expect(subject.short_description).to eq(short_description)
          expect(subject.path).to eq('/api/users/:id')
          expect(subject.from_routes).to eq(true)
          expect(subject.options).to eq({ from_routes: true })
        end

        context "when it's from concern" do
          let(:controller) { ConcernsController }
          let(:controller_action) { :custom }
          let(:dsl) { super().merge(from_concern: true ) }

          it 'has the correct values' do
            expect(subject.short_description).to eq(short_description)
            expect(subject.path).to eq('/api/concern_resources/custom')
            expect(subject.from_routes).to eq(true)
            expect(subject.options).to eq({ from_routes: true })
          end
        end
      end
    end
  end
end
