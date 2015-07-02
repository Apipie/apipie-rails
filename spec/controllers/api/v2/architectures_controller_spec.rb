require 'spec_helper'

describe Api::V2::ArchitecturesController do
  describe "resource description" do
    subject { Apipie.get_resource_description(Api::V2::ArchitecturesController, "2.0") }

    it "should be version 2.0" do
      expect(subject._version).to eq('2.0')
    end

  end
end
