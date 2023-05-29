require 'spec_helper'

describe Api::V2::EmptyMiddleController do
  let(:resource_description) { Apipie.get_resource_description(described_class, '2.0') }

  describe 'resource description' do
    subject { resource_description }

    context 'when namespaced resources are enabled' do
      before { Apipie.configuration.namespaced_resources = true }
      after { Apipie.configuration.namespaced_resources = false }

      # we don't actually expect the resource description to be nil, but resource IDs
      # are computed at file load time, and altering the value of namespaced_resources
      # after the fact doesn't change the resource ID, so it can't be found
      it { is_expected.to be_nil }
    end

    context 'when namespaced resources are disabled' do
      it { is_expected.to be_nil }
    end
  end
end
