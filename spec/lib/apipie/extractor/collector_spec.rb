# frozen_string_literal: true

require 'spec_helper'

describe Apipie::Extractor::Collector do
  let(:recorder) { described_class.new }

  describe '#ignore_call?' do
    subject { recorder.ignore_call?(record) }

    let(:record) { { controller: controller, action: action } }
    let(:controller) { ActionController::Base }
    let(:action) { nil }

    context 'when controller is nil' do
      let(:controller) { nil }

      it { is_expected.to be true }
    end

    context 'when controller is ignored' do
      before do
        allow(Apipie.configuration).to receive(:ignored_by_recorder).and_return(['ActionController::Bas'])
      end

      it { is_expected.to be true }
    end

    context 'when resource#method is ignored' do
      let(:action) { 'ignored_action' }

      before do
        allow(Apipie.configuration).to receive(:ignored_by_recorder).and_return(['ActionController::Bas#ignored_action'])
      end

      it { is_expected.to be true }
    end

    context 'when controller is not an API controller' do
      before do
        allow(Apipie::Extractor).to receive(:controller_path).with('action_controller/base').and_return('foo')
        allow(Apipie).to receive(:api_controllers_paths).and_return([])
      end

      it { is_expected.to be true }
    end

    context 'when controller is an API controller' do
      before do
        allow(Apipie::Extractor).to receive(:controller_path).with('action_controller/base').and_return('foo')
        allow(Apipie).to receive(:api_controllers_paths).and_return(['foo'])
      end

      it { is_expected.to be_falsey }
    end
  end
end
