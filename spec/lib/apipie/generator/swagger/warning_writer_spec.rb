require 'spec_helper'

describe Apipie::Generator::Swagger::WarningWriter do
  let(:writer) { described_class.clone.instance }

  let(:warning) do
    Apipie::Generator::Swagger::Warning.for_code(
      Apipie::Generator::Swagger::Warning::INFERRING_BOOLEAN_CODE,
      'SampleController#action',
      { parameter: 'some-param' }
    )
  end

  before do
    Apipie.configuration.swagger_suppress_warnings = false
    Singleton.__init__(described_class)
  end

  describe '#warn' do
    subject { writer.warn(warning) }

    it 'outputs the warning' do
      expect { subject }.to output(warning.warning_message).to_stderr
    end

    context 'when Apipie.configuration.swagger_suppress_warnings is true' do
      before { Apipie.configuration.swagger_suppress_warnings = true }

      it { is_expected.to be_falsey }
    end

    context 'when Apipie.configuration.swagger_suppress_warnings includes warning code' do
      before do
        Apipie.configuration.swagger_suppress_warnings =
          Array(Apipie::Generator::Swagger::Warning::INFERRING_BOOLEAN_CODE)
      end

      it { is_expected.to be_falsey }
    end

    context 'when a warning already been logged' do
      before { writer.warn(warning) }

      it { is_expected.to be_falsey }
    end
  end

  describe '#issued_warnings?' do
    subject { writer.issued_warnings? }

    it { is_expected.to be_falsey }

    context 'when a warning already been logged' do
      before { writer.warn(warning) }

      it { is_expected.to be_truthy }
    end
  end
end
