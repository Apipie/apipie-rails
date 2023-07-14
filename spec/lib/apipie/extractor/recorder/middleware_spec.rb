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

  describe 'with a multipart post' do
    let(:form_hash) do
      {
        'stringbody' => 'this is a string body',
        'filebody' => {:head => 'X-Fake-Header: fake1\r\n'},
        'files' => {
          '0' => {:head => 'X-Fake-Header: fake2\r\n'}
        }
      }
    end

    let(:response) do
      request.post('/', 'rack.request.form_hash' => form_hash)
    end

    it 'reformats form parts' do
      Apipie.configuration.record = true
      # expect reformat_multipart_data to invoke content_disposition
      expect(Apipie::Extractor.call_recorder).to receive(:content_disposition)
      response
    end
  end
end
