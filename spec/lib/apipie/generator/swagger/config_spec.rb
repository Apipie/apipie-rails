require 'spec_helper'

describe Apipie::Generator::Swagger::Config do
  let(:config) { described_class.clone.instance }

  before { Singleton.__init__(described_class) }

  describe 'deprecation warnings' do
    context 'when a deprecated method is call' do
      subject(:deprecated_method_call) { config.swagger_include_warning_tags? }

      it 'returns a deprecations warning' do
        expect { deprecated_method_call }
          .to output(/DEPRECATION WARNING: config.swagger_include_warning_tags is deprecated/)
          .to_stderr
      end
    end
  end
end
