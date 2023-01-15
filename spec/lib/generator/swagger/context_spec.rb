require 'spec_helper'

describe Apipie::Generator::Swagger::Context do
  let(:allow_null) { true }
  let(:in_schema) { true }
  let(:http_method) { 'get' }

  subject do
    described_class.new(
      allow_null: allow_null,
      http_method: http_method,
      in_schema: in_schema,
      controller_method: 'show'
    )
  end

  describe '#in_schema?' do
    it { is_expected.to be_in_schema }
    context 'when in_schema is false' do
      let(:in_schema) { false }

      it { is_expected.not_to be_in_schema }
    end
  end

  describe '#allow_null?' do
    it { is_expected.to be_allow_null }

    context 'when allow_null is false' do
      let(:allow_null) { false }

      it { is_expected.not_to be_allow_null }
    end
  end
end
