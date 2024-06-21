require "spec_helper"

describe Apipie::MethodDescription do
  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }
  let(:deprecated_resource_description) { false }
  let(:method_description_method) { :some_method }

  let(:resource_description_dsl) do
    ActionController::Base.send(:_apipie_dsl_data_init).merge(
      {
        deprecated: deprecated_resource_description
      }
    )
  end

  let(:resource_description) do
    Apipie::ResourceDescription.new(
      ApplicationController,
      'dummy',
      resource_description_dsl
    )
  end

  let(:method_description) do
    Apipie::MethodDescription.new(
      method_description_method,
      resource_description,
      dsl_data
    )
  end

  describe '#to_json' do
    describe 'metadata' do
      subject { method_description.to_json[:metadata] }

      it { is_expected.to be_nil }

      context 'when meta are given' do
        let(:meta) { { length: 32, weight: '830g' } }
        let(:dsl_data) { super().merge(meta: meta) }

        it { is_expected.to eq(meta) }
      end
    end

    describe 'params' do
      subject(:json_params) { method_description.to_json[:params].map { |h| h[:name] } }

      let(:dsl_data) do
        super().merge(
          {
            params: [
              [:a, String, nil, {}, nil],
              [:b, String, nil, {}, nil],
              [:c, String, nil, {}, nil]
            ]
          }
        )
      end

      it 'is ordered' do
        expect(json_params).to eq(%w[a b c])
      end

      context 'when param is only for response' do
        let(:dsl_data) do
          super().merge(
            {
              params: [
                [:a, String, nil, { only_in: :request }, nil],
                [:b, String, nil, { only_in: :response }, nil],
                [:c, String, nil, {}, nil]
              ]
            }
          )
        end

        it 'ignores response-only parameters' do
          expect(json_params).to eq(%w[a c])
        end
      end
    end
  end

  describe '#method_apis_to_json' do
    describe 'deprecated' do
      subject { method_description.method_apis_to_json.first[:deprecated] }

      let(:api_deprecated) { false }
      let(:dsl_data) { super().merge(api_args: api_args) }

      let(:api_args) do
        [[:GET, "/foo/bar", "description", { deprecated: api_deprecated }]]
      end

      it { is_expected.to eq(false) }

      context 'when api is deprecated' do
        let(:api_deprecated) { true }

        it { is_expected.to eq(true) }
      end

      context 'when resource description is deprecated' do
        let(:deprecated_resource_description) { true }

        it { is_expected.to eq(true) }
      end
    end
  end

  describe '#returns' do
    subject(:method_desc) { method_description }

    context 'when both :param_group and :array_of are specified' do
      let(:returns) do
        { 200 => [{ param_group: 'pet', array_of: 'pet' }, nil, nil] }
      end

      let(:dsl_data) { super().merge({ returns: returns }) }

      it 'raises an error' do
        expect { method_desc }.to raise_error(Apipie::ReturnsMultipleDefinitionError)
      end
    end
  end

  describe '#method_name' do
    subject { method_description.method_name }

    it { is_expected.to eq(method_description_method.to_s) }
  end
end
