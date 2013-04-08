require "spec_helper"

describe Apipie::Application do

  describe "get_resource_name" do
    subject {Apipie.get_resource_name(Api::V2::Nested::ArchitecturesController)}

    context "with namespaced_resources enabled" do
      before { Apipie.configuration.namespaced_resources = true }
      context "with a defined base url" do
        
        it "should not overwrite the parent resource" do
          should_not eq(Apipie.get_resource_name(Api::V2::ArchitecturesController))
        end
        
      end

      context "with an undefined base url" do
        before {Apipie.app.stub(:get_base_url) { nil }}

        it "should not raise an error" do
          expect { Apipie.get_resource_name(Api::V2::ArchitecturesController) }.
            not_to raise_error
        end
      end

      after { Apipie.configuration.namespaced_resources = false }
    end

    context "with namespaced_resources enabled" do
      before { Apipie.configuration.namespaced_resources = false }

      it "should overwrite the the parent" do
        should eq(Apipie.get_resource_name(Api::V2::ArchitecturesController))
      end
    end
  end
end
