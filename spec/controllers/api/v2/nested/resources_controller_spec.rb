require 'spec_helper'

describe Api::V2::Nested::ResourcesController do
  describe '.get_resource_id' do
    subject { Apipie.get_resource_id(Api::V2::Nested::ResourcesController) }

    it "should have resource_id set" do
      expect(subject).to eq("resource")
    end
  end
end
