require 'spec_helper'

describe Api::V2::Nested::ResourcesController do
  let(:resource_description) { Apipie.get_resource_description(described_class, "2.0") }

  describe "resource description" do
    describe 'version' do
      subject { resource_description._version }

      it { is_expected.to eq('2.0') }
    end

    describe 'name' do
      subject { resource_description.name }

      it { is_expected.to eq('Rsrcs') }
    end
  end

  describe '.get_resource_id' do
    subject { Apipie.get_resource_id(Api::V2::Nested::ResourcesController) }

    it "has resource_id set" do
      expect(subject).to eq("resource")
    end
  end
end
