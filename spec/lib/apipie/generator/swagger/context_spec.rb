require 'spec_helper'

describe Apipie::Generator::Swagger::Context do
  let(:allow_null) { true }
  let(:in_schema) { true }
  let(:http_method) { 'get' }
  let(:prefix) { nil }

  let(:context_instance) do
    described_class.new(
      allow_null: allow_null,
      http_method: http_method,
      in_schema: in_schema,
      controller_method: 'show',
      prefix: prefix
    )
  end

  describe '#in_schema?' do
    subject { context_instance }

    it { is_expected.to be_in_schema }

    context 'when in_schema is false' do
      let(:in_schema) { false }

      it { is_expected.not_to be_in_schema }
    end
  end

  describe '#allow_null?' do
    subject { context_instance }

    it { is_expected.to be_allow_null }

    context 'when allow_null is false' do
      let(:allow_null) { false }

      it { is_expected.not_to be_allow_null }
    end
  end

  describe '#add_to_prefix!' do
    before { context_instance.add_to_prefix!('some-prefix') }

    subject { context_instance.prefix }

    it { is_expected.to eq('some-prefix') }

    context 'when context has already a prefix' do
      let(:prefix) { 'existing-prefix' }

      it { is_expected.to eq('existing-prefix[some-prefix]') }
    end
  end
end
