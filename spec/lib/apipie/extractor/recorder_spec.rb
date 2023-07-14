# frozen_string_literal: true

require 'spec_helper'

describe 'Apipie::Extractor::Recorder' do
  let(:recorder) { Apipie::Extractor::Recorder.new }
  let(:controller) do
    controller = ActionController::Metal.new
    controller.set_request!(request)
    controller
  end

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

    it { is_expected.to eq(action) }

    context 'when a api_action_matcher is configured' do
      let(:matcher_action) { "#{action}_from_new_matcher" }

      before do
        Apipie.configuration.api_action_matcher = proc { |_| matcher_action }
      end

      it { is_expected.to eq(matcher_action) }
    end
  end

  describe '#analyse_functional_test' do
    context 'with multipart-form data' do
      subject do
        recorder.analyse_controller(controller)
        recorder.analyze_functional_test(test_context)
        recorder.record[:request_data]
      end

      let(:test_context) do
        double(controller: controller, request: request, response: ActionDispatch::Response.new(200))
      end

      let(:file) do
        instance_double(
          ActionDispatch::Http::UploadedFile,
          original_filename: 'file.txt',
          content_type: 'text/plain',
          size: '1MB'
        )
      end

      let(:request) do
        request = ActionDispatch::Request.new({})
        request.request_method = 'POST'
        request.headers['Content-Type'] = 'multipart/form-data'
        request.request_parameters = { file: file }
        request
      end

      before do
        allow(file).to receive(:is_a?).and_return(false)
        allow(file).to receive(:is_a?).with(ActionDispatch::Http::UploadedFile).and_return(true)
      end

      it { is_expected.to include("filename=\"#{file.original_filename}\"") }
    end
  end
end
