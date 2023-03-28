require "spec_helper"

describe Apipie::ResourceDescription do
  let(:resource_description) do
    Apipie::ResourceDescription.new(controller, name, dsl_data)
  end

  let(:controller) { ApplicationController }
  let(:name) { 'dummy' }
  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  describe '#_methods' do
    subject(:methods) { resource_description._methods }

    context 'when has method descriptions' do
      before do
        resource_description.add_method_description(
          Apipie::MethodDescription.new(:a, resource_description, dsl_data)
        )
        resource_description.add_method_description(
          Apipie::MethodDescription.new(:b, resource_description, dsl_data)
        )
        resource_description.add_method_description(
          Apipie::MethodDescription.new(:c, resource_description, dsl_data)
        )
      end

      it 'should be ordered' do
        expect(methods.keys).to eq([:a, :b, :c])
      end
    end
  end

  describe '#to_json' do
    let(:json_data) { resource_description.to_json }

    describe 'metadata' do
      subject { json_data[:metadata] }

      it { is_expected.to be_nil }

      context 'when meta data are provided' do
        let(:meta) { { length: 32, weight: '830g' } }
        let(:dsl_data) { super().update({ meta: meta }) }

        it { is_expected.to eq(meta) }
      end
    end

    describe 'methods' do
      subject(:methods_as_json) { json_data[:methods] }

      context 'when has method descriptions' do
        before do
          resource_description.add_method_description(
            Apipie::MethodDescription.new(:a, resource_description, dsl_data)
          )
          resource_description.add_method_description(
            Apipie::MethodDescription.new(:b, resource_description, dsl_data)
          )
          resource_description.add_method_description(
            Apipie::MethodDescription.new(:c, resource_description, dsl_data)
          )
        end

        it 'should be ordered' do
          expect(methods_as_json.map { |h| h[:name] }).to eq(['a', 'b', 'c'])
        end
      end
    end
  end
end
