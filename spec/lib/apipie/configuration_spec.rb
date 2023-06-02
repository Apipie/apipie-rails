# frozen_string_literal: true

require 'spec_helper'

describe 'Apipie::Configuration' do
  let(:configuration) { Apipie::Configuration.new }

  describe '#api_action_matcher=' do
    subject(:setter) { configuration.api_action_matcher = matcher }

    let(:matcher) { proc { |_| :some_action } }

    it { is_expected.to eq(matcher) }

    context 'when matcher does not implement .call method' do
      let(:matcher) { 'I do not implement .call' }

      it 'raises and exception' do
        expect { setter }.to raise_error('Must implement .call method')
      end
    end
  end

  describe 'generator configuration' do
    let(:generator_config) { configuration.generator }

    describe '#swagger' do
      subject(:setter) { generator_config.swagger.include_warning_tags = true }

      it 'assigns the correct value' do
        expect { setter }
          .to change(configuration.generator.swagger, :include_warning_tags?)
          .from(false)
          .to(true)
      end
    end
  end
end
