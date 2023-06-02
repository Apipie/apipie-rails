require "spec_helper"

describe Apipie::ParamDescription::Deprecation do
  let(:info) { nil }
  let(:deprecated_in) { nil }
  let(:sunset_at) { nil }

  let(:deprecation) do
    described_class.new(
      info: info,
      deprecated_in: deprecated_in,
      sunset_at: sunset_at
    )
  end

  describe '#to_json' do
    subject { deprecation.to_json }

    it { is_expected.to eq({ info: nil, deprecated_in: nil, sunset_at: nil }) }

    context 'when attributes are given' do
      let(:info) { 'info' }
      let(:deprecated_in) { '2.3' }
      let(:sunset_at) { '3.0' }

      it 'returns the correct attributes' do
        expect(subject).to eq({ info: info, deprecated_in: deprecated_in, sunset_at: sunset_at })
      end
    end
  end
end
