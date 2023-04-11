require 'spec_helper'

describe Apipie::Generator::Swagger::PathDecorator do
  let(:decorated_path) { described_class.new(path) }

  describe '#param_names' do
    subject { decorated_path.param_names }

    context 'when path does not contain any params' do
      let(:path) { 'some/path/without_params' }

      it { is_expected.to be_empty }
    end

    context 'when path has a param' do
      let(:path) { '/:resource_id/custom' }

      it { is_expected.to eq([:resource_id]) }
    end
  end

  describe '#param?' do
    subject { decorated_path.param?(param) }

    context 'when path has params' do
      let(:path) { '/:resource_id/custom' }

      context 'when param to check is in the path' do
        let(:param) { :resource_id }

        it { is_expected.to be(true) }
      end

      context 'when param to check is not in the path' do
        let(:param) { :some_param }

        it { is_expected.to be(false) }
      end
    end
  end

  describe '#swagger_path' do
    subject(:swagger_path) { decorated_path.swagger_path }

    let(:path) { '/some/custom/path' }

    it { is_expected.to eq('/some/custom/path') }

    context 'when path does not start with slash' do
      let(:path) { ':resource_id/custom' }

      it 'adds the slash in the beginning' do
        expect(swagger_path).to eq('/{resource_id}/custom')
      end
    end
  end
end
