require "spec_helper"

describe Apipie::Application do

  describe "get_resource_name" do
    subject {Apipie.get_resource_name(Api::V2::Nested::ArchitecturesController)}
    context "with namespaced_resources enabled" do
      before { Apipie.configuration.namespaced_resources = true }

      it "should not overwrite the parent resource" do
        subject.should_not eq(Apipie.get_resource_name(Api::V2::ArchitecturesController))
      end
    end

    context "with namespaced_resources enabled" do
      before { Apipie.configuration.namespaced_resources = false }

      it "should overwrite the the parent" do
        subject.should eq(Apipie.get_resource_name(Api::V2::ArchitecturesController))
      end
    end
  end
end
