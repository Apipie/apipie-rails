require "spec_helper"

describe Apipie::Application do

  describe "api_controllers_paths" do
    before do
      Apipie.configuration.api_controllers_matcher = [File.join(Rails.root, "app", "controllers", "**","*.rb"),
                                                      File.join(Rails.root, "lib", "**","*.rb")]
    end

    it "should support receiving array as parameter" do
      expect { Apipie.api_controllers_paths}.
        not_to raise_error
    end


  end

  describe '.get_resource_name' do
    subject(:get_resource_name) do
      Apipie.get_resource_name(Api::V2::Nested::ArchitecturesController)
    end

    let(:base_url) { '/some-api' }

    before { allow(Apipie.app).to receive(:get_base_url).and_return(base_url) }

    context "with namespaced_resources enabled" do
      before { Apipie.configuration.namespaced_resources = true }
      after { Apipie.configuration.namespaced_resources = false }

      it "returns the namespaces" do
        is_expected.to eq('api-v2-nested-architectures')
      end

      context "with an undefined base url" do
        let(:base_url) { nil }

        it "should not raise an error" do
          expect { get_resource_name }.not_to raise_error
        end
      end
    end

    context "with namespaced_resources disabled" do
      before { Apipie.configuration.namespaced_resources = false }

      it "returns the controller name" do
        is_expected.to eq('architectures')
      end
    end
  end
end
