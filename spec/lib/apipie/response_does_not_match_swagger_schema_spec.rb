require 'spec_helper'

describe Apipie::ResponseDoesNotMatchSwaggerSchema do
  let(:error) do
    described_class.new(
      controller_name,
      method_name,
      response_code,
      error_messages,
      schema,
      returned_object
    )
  end

  let(:controller_name) { 'UserController' }
  let(:method_name) { 'index' }
  let(:response_code) { 200 }
  let(:error_messages) { [] }
  let(:schema) { {} }
  let(:returned_object) { {} }

  describe '#to_s' do
    subject { error.to_s }

    let(:error_message) do
      <<~HEREDOC.chomp
        Response does not match swagger schema (#{controller_name}##{method_name} #{response_code}): #{error_messages}
        Schema: #{JSON(schema)}
        Returned object: #{returned_object}
      HEREDOC
    end

    it { is_expected.to eq(error_message) }
  end
end
