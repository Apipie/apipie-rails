require "spec_helper"

describe Apipie::FileHandler do

  describe "match?" do
    let(:file_handler) { Apipie::FileHandler.new File.dirname(__FILE__) }

    it { expect(file_handler.match? 'file_handler_spec.rb').to be_truthy }
    it { expect(file_handler.match? 'foo.bar').to be_falsy }

    context 'path contains null bytes' do
      let(:path) { "foo%00.bar" }

      it { expect(file_handler.match? path).to be_falsy }
      it { expect { file_handler.match? path }.to_not raise_error }
    end

    context 'when the path contains an invalid byte sequence in UTF-8' do
      let(:path) { "%B6" }

      it { expect(file_handler.match? path).to be_falsy }
      it { expect { file_handler.match? path }.to_not raise_error }
    end
  end
end
