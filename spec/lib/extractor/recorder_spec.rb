# frozen_string_literal: true

require 'spec_helper'

describe 'Apipie::Extractor::Recorder' do
  let(:recorder) { Apipie::Extractor::Recorder.new }

  describe '#analyse_controller' do
    subject do
      recorder.analyse_controller(controller)
      recorder.record[:action]
    end

    let(:action) { :show }

    let(:request) do
      request = ActionDispatch::Request.new({})
      request.request_parameters = { action: action }
      request
    end

    let(:controller) do
      controller = ActionController::Metal.new
      controller.set_request!(request)
      controller
    end

    it { is_expected.to eq(action) }

    context 'when a api_action_matcher is configured' do
      let(:matcher_action) { "#{action}_from_new_matcher" }

      before do
        Apipie.configuration.api_action_matcher = proc { |_| matcher_action }
      end

      it { is_expected.to eq(matcher_action) }
    end
  end
end
