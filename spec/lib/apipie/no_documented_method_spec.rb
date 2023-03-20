require 'spec_helper'

describe Apipie::NoDocumentedMethod do
  let(:error) { described_class.new(controller_name, method_name) }
  let(:controller_name) { 'UserController' }
  let(:method_name) { 'index' }

  describe '#to_s' do
    subject { error.to_s }

    let(:error_message) do
      "There is no documented method #{controller_name}##{method_name}"
    end

    it { is_expected.to eq(error_message) }
  end
end
