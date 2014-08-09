require "spec_helper"

describe Apipie::Extractor::Recorder::Middleware do
  let(:app) { lambda { |env| [200, env, "app"] } }
  let(:stack) { Apipie::Extractor::Recorder::Middleware.new(app) }
  let(:request) { Rack::MockRequest.new(stack) }
  let(:response) { request.get('/') }

  it 'correctly process request without recording' do
    expect(stack).not_to receive(:analyze)
    response
  end

  it "analyze request if recording is set" do
    Apipie.configuration.record = true
    expect(Apipie::Extractor.call_recorder).to receive(:analyse_env)
    expect(Apipie::Extractor.call_recorder).to receive(:analyse_response)
    expect(Apipie::Extractor).to receive(:clean_call_recorder)
    response
  end
end
