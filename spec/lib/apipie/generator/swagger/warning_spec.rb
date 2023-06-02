require "spec_helper"

describe Apipie::Generator::Swagger::Warning do
  let(:code) { Apipie::Generator::Swagger::Warning::MISSING_METHOD_SUMMARY_CODE }
  let(:method_id) { 'Examples#index' }
  let(:info_message) { 'Something went wrong' }

  let(:warning) { described_class.new(code, info_message, method_id) }

  describe '#id' do
    subject { warning.id }

    it { is_expected.to eq("#{method_id}#{code}#{info_message}") }
  end

  describe '#warning_message' do
    subject { warning.warning_message }

    it { is_expected.to eq("WARNING (#{code}): [#{method_id}] -- #{info_message}\n") }
  end

  describe '#warn' do
    subject { warning.warn }

    it 'outputs the warning' do
      expect { subject }.to output(warning.warning_message).to_stderr
    end
  end

  describe '#warn_through_writer' do
    subject { warning.warn }

    it 'outputs the warning' do
      expect { subject }.to output(warning.warning_message).to_stderr
    end
  end

  describe '.for_code' do
    subject { described_class.for_code(code, method_id) }

    it { is_expected.to be_an_instance_of(described_class)}

    context 'when code is invalid' do
      let(:code) { 12345 }

      it 'raises an argument error' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end
end
