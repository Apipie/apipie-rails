require 'spec_helper'

RSpec.describe Apipie::Routing::MapperExtensions do
  let(:routes) { ActionDispatch::Routing::RouteSet.new }
  let(:version) { 'v1' }
  let(:resource) { 'users' }
  let(:api_method) { 'show' }
  let(:path) { "/apidoc/#{version}/#{resource}/#{api_method}" }

  describe '#apipie' do
    before { routes.draw { apipie } }

    it 'preserves the default route helper and mapping', :aggregate_failures do
      expect(routes.url_helpers.apipie_apipie_path(version: version, resource: resource, method: api_method)).to eq(path)

      expect(routes.recognize_path(path, method: :get)).to include(
        controller: 'apipie/apipies',
        action: 'index',
        version: version,
        resource: resource,
        method: api_method
      )
    end
  end
end
