require 'spec_helper'

describe Api::V2::ArchitecturesController do
  describe "resource description" do
    subject { Apipie.get_resource_description(Api::V2::ArchitecturesController) }

    it "should be version 2.0" do
      subject._version.should eq('2.0')
    end

  end
end
