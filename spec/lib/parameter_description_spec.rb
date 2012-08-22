require "spec_helper"

describe Apipie::ParamDescription do

  describe "required_by_default config option" do

    context "parameters required by default" do

      before { Apipie.configuration.required_by_default = true }

      it "should set param as required by default" do
        param = Apipie::ParamDescription.new(:required_by_default, String)
        param.required.should be_true
      end

      it "should be possible to set param as optional" do
        param = Apipie::ParamDescription.new(:optional, String, :required => false)
        param.required.should be_false
      end

    end

    context "parameters optional by default" do

      before { Apipie.configuration.required_by_default = false }

      it "should set param as optional by default" do
        param = Apipie::ParamDescription.new(:optional_by_default, String)
        param.required.should be_false
      end

      it "should be possible to set param as required" do
        param = Apipie::ParamDescription.new(:required, String, 'description','required' => true)
        param.required.should be_true
      end

    end

  end

end