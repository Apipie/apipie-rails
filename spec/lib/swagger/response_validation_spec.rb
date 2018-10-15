require 'spec_helper'
require 'rack/utils'
require 'rspec/expectations'
require 'apipie/rspec/response_validation_helper'
require "json-schema"

RSpec.describe PetsController, :type => :controller do
  before :each do
    Apipie.configuration.swagger_allow_additional_properties_in_response = false
  end

  it "does not raise error when rendered output matches the described response" do
    response = get :return_and_validate_expected_response, {format: :json}
    expect(response).to match_declared_responses
  end

  it "does not raise error when rendered output (array) matches the described response" do
    response = get :return_and_validate_expected_array_response, {format: :json}
    expect(response).to match_declared_responses
  end

  it "does not raises error when rendered output includes null in the response" do
    response = get :return_and_validate_expected_response_with_null, {format: :json}
    expect(response).to match_declared_responses
  end

  it "does not raise error when rendered output includes null (instead of an object) in the response" do
    response = get :return_and_validate_expected_response_with_null_object, {format: :json}
    expect(response).to match_declared_responses
  end

  it "raises error when a response field has the wrong type" do
    response = get :return_and_validate_type_mismatch, {format: :json}
    expect(response).not_to match_declared_responses
  end

  it "raises error when a response has a missing field" do
    response = get :return_and_validate_missing_field, {format: :json}
    expect(response).not_to match_declared_responses
  end

  it "raises error when a response has an extra property and 'swagger_allow_additional_properties_in_response' is false" do
    response = get :return_and_validate_extra_property, {format: :json}
    expect(response).not_to match_declared_responses
  end

  it "raises error when a response has is array instead of object" do
    # note: this action returns HTTP 201, not HTTP 200!
    response = get :return_and_validate_unexpected_array_response, {format: :json}
    expect(response).not_to match_declared_responses
  end

  it "does not raise error when a response has an extra property and 'swagger_allow_additional_properties_in_response' is true" do
    Apipie.configuration.swagger_allow_additional_properties_in_response = true
    response = get :return_and_validate_extra_property, {format: :json}
    expect(response).to match_declared_responses
  end

  it "does not raise error when a response has an extra field and 'additional_properties' is specified in the response" do
    Apipie.configuration.swagger_allow_additional_properties_in_response = false
    response = get :return_and_validate_allowed_extra_property, {format: :json}
    expect(response).to match_declared_responses
  end

  it "raises error when a response sub-object has an extra field and 'additional_properties' is not specified on it, but specified on the top level of the response" do
    Apipie.configuration.swagger_allow_additional_properties_in_response = false
    response = get :sub_object_invalid_extra_property, {format: :json}
    expect(response).not_to match_declared_responses
  end

  it "does not rais error when a response sub-object has an extra field and 'additional_properties' is specified on it" do
    Apipie.configuration.swagger_allow_additional_properties_in_response = false
    response = get :sub_object_allowed_extra_property, {format: :json}
    expect(response).to match_declared_responses
  end

  describe "auto validation" do
    auto_validate_rendered_views
    it "raises exception when a response field has the wrong type and auto validation is turned on" do
      expect { get :return_and_validate_type_mismatch, {format: :json} }.to raise_error(Apipie::ResponseDoesNotMatchSwaggerSchema)
    end

    it "does not raise an exception when calling an undocumented method" do
      expect { get :undocumented_method, {format: :json} }.not_to raise_error
    end

  end


  describe "with array field" do
    it "no error for valid response" do
      response = get :returns_response_with_valid_array, {format: :json}
      expect(response).to match_declared_responses
    end

    it "error if type of element in the array is wrong" do
      response = get :returns_response_with_invalid_array, {format: :json}
      expect(response).not_to match_declared_responses
    end
  end



end
