require 'spec_helper'

describe Api::V2::Nested::ResourcesController do
  describe "resource id" do
    subject { Apipie.get_resource_name(Api::V2::Nested::ResourcesController) }

    it "should have resource_id set" do
      expect(subject).to eq("resource")
    end
  end
end
