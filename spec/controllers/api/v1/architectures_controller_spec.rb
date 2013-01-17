require 'spec_helper'

describe Api::V1::ArchitecturesController do
  describe "resource description" do
    subject { Apipie.get_resource_description(Api::V1::ArchitecturesController, "1.0") }

    it "should be version 1.0" do
      subject._version.should eq('1.0')

      Apipie.resource_descriptions['1.0'].size.should == 2
      Apipie.resource_descriptions['1.0'].keys.should
        include('architectures', 'base')
    end

    context "there is another version" do
      let(:v2) { archv2 = Apipie.get_resource_description(Api::V2::ArchitecturesController, "2.0") }

      it "should have unique doc url" do
        subject.doc_url.should_not eq(v2.doc_url)
      end

      it "should have unique methods" do
        subject._methods.keys.should include(:index)
        v2._methods.keys.should include(:index)
        subject._methods[:index].should_not eq(v2._methods[:index])
      end

    end
  end
end
