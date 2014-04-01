require "spec_helper"

describe ConcernsController do

  it "displays is every controller the concern is included" do
    Apipie["concern_resources#index"].should be
    Apipie["concern_resources#show"].should be
  end

  it "should reply to valid request" do
    get :show, :id => '5', :session => "secret_hash"
    assert_response :success
  end

  it "should pass if required parameter is missing" do
    lambda { get :show, :id => '5' }.should_not raise_error
  end

  it "peserved the order of methods being defined in file" do
    doc_methods = Apipie.get_resource_description('concern_resources')._methods.keys
    doc_methods.should == [:index, :show, :create, :update, :custom]
  end

  it "replaces a placeholder doc specified in concern with a real path" do
    path = Apipie["concern_resources#index"].apis.first.path
    path.should == '/concerns'

    path = Apipie["concern_resources#show"].apis.first.path
    path.should == '/concern_resources/:id'

    path = Apipie["concern_resources#custom"].apis.first.path
    path.should == '/concern_resources/custom'
  end

  it "replaces placeholders in param names and descriptions" do
    create_desc = Apipie["concern_resources#create"].params[:user]
    name_param, concern_type_param = create_desc.validator.params_ordered
    name_param.desc.should include "Name of a user"
    concern_type_param.name.should == :user_type
  end
end

