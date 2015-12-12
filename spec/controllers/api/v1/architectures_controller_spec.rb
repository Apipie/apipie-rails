require 'spec_helper'

describe Api::V1::ArchitecturesController do
  describe "resource description" do
    subject { Apipie.get_resource_description(Api::V1::ArchitecturesController, "1.0") }

    it "should be version 1.0" do
      expect(subject._version).to eq('1.0')

      expect(Apipie.resource_descriptions['1.0'].size).to eq(2)
      expect(Apipie.resource_descriptions['1.0'].keys).to include('architectures', 'base')
    end

    context "there is another version" do
      let(:v2) { archv2 = Apipie.get_resource_description(Api::V2::ArchitecturesController, "2.0") }

      it "should have unique doc url" do
        expect(subject.doc_url).not_to eq(v2.doc_url)
      end

      it "should have unique methods" do
        expect(subject._methods.keys).to include(:index)
        expect(v2._methods.keys).to include(:index)
        expect(subject._methods[:index]).not_to eq(v2._methods[:index])
      end

    end
  end
end
