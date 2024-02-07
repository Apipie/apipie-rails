require 'spec_helper'


describe IncludedParamGroupController do

  let(:dsl_data) { ActionController::Base.send(:_apipie_dsl_data_init) }

  it "does not error when there is a param_group that is deeply nested in response description" do
    subject = Apipie.get_resource_description(IncludedParamGroupController, Apipie.configuration.default_version)
    expect(subject._methods.keys).to include(:show)
  end

end
