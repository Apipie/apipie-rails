require 'spec_helper'

describe Apipie::ResponseDescription::ResponseObject do
  describe '#header' do
    let(:response_object) { described_class.new(nil, nil, nil, nil) }
    let(:name) { 'Current-Page' }
    let(:description) { 'The current page in the pagination' }

    before { response_object.header(name, String, description) }

    it 'adds it to the headers' do
      expect(response_object.headers).to(
        contain_exactly({
                          name: name,
                          description: description,
                          validator: 'string',
                          options: {}
                        })
      )
    end
  end
end
