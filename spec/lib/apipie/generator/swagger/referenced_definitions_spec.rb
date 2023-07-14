require 'spec_helper'

describe Apipie::Generator::Swagger::ReferencedDefinitions do
  let(:definitions) { described_class.instance }

  before { Singleton.__init__(described_class) }

  describe '.add!' do
    subject(:add_call) { definitions.add!(param_type, schema) }

    let(:param_type) { :some_type }
    let(:schema) { { key: 'value' } }

    it 'returns add the definition' do
      expect { add_call }
        .to change(definitions, :definitions)
        .from({})
        .to({ param_type => schema })
    end
  end

  describe '.added?' do
    subject { definitions.added?(param_type) }

    let(:param_type) { :some_type }

    it { is_expected.to be_blank }

    context 'when definition exists' do
      before { definitions.add!(param_type, {}) }

      it { is_expected.to be(true) }
    end
  end
end
