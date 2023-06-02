#----------------------------------------------------------------------------------------------
# response_validation_helper.rb:
#
# this is an rspec utility to allow validation of responses against the swagger schema generated
# from the Apipie 'returns' definition for the call.
#
#
# to use this file in a controller rspec you should
# require 'apipie/rspec/response_validation_helper' in the spec file
#
#
# this utility provides two mechanisms:  matcher-based validation and auto-validation
#
#   matcher-based: an rspec matcher allowing 'expect(response).to match_declared_responses'
#   auto-validation: all responses returned from 'get', 'post', etc. are automatically tested
#
# ===================================
# Matcher-based validation - example
# ===================================
# Assume the file 'my_controller_spec.rb':
#
#     require 'apipie/rspec/response_validation_helper'
#
#     RSpec.describe MyController, :type => :controller, :show_in_doc => true do
#
#     describe "GET stuff with response validation" do
#       render_views   # this makes sure the 'get' operation will actually
#                      # return the rendered view even though this is a Controller spec
#
#       it "does something" do
#         response = get :index, {format: :json}
#
#         # the following expectation will fail if the returned object
#         # does not match the 'returns' declaration in the Controller,
#         # or if there is no 'returns' declaration for the returned
#         # HTTP status code
#         expect(response).to match_declared_responses
#       end
#     end
#
#
# ===================================
# Auto-validation
# ===================================
# To use auto-validation, at the beginning of the block in which you want to turn on validation:
#    -) turn on view rendering (by stating 'render_views')
#    -) turn on response validation by stating 'auto_validate_rendered_views'
#
# For example, assume the file 'my_controller_spec.rb':
#
#     require 'apipie/rspec/response_validation_helper'
#
#     RSpec.describe MyController, :type => :controller, :show_in_doc => true do
#
#     describe "GET stuff with response validation" do
#       render_views
#       auto_validate_rendered_views
#
#       it "does something" do
#         get :index, {format: :json}
#       end
#       it "does something else" do
#         get :another_index, {format: :json}
#       end
#     end
#
#     describe "GET stuff without response validation" do
#       it "does something" do
#         get :index, {format: :json}
#       end
#       it "does something else" do
#         get :another_index, {format: :json}
#       end
#     end
#
#
# Once this is done, responses from http operations ('get', 'post', 'delete', etc.)
# will fail the test if the response structure does not match the 'returns' declaration
# on the method (for the actual HTTP status code), or if there is no 'returns' declaration
# for the HTTP status code.
#----------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------
# Response validation: core logic  (used by auto-validation and manual-validation mechanisms)
#----------------------------------------------------------------------------------------------
class ActionController::Base
  module Apipie::ControllerValidationHelpers
    # this method is injected into ActionController::Base in order to
    # get access to the names of the current controller, current action, as well as to the response
    def schema_validation_errors_for_response
      unprocessed_schema = Apipie::json_schema_for_method_response(controller_name, action_name, response.code, true)

      if unprocessed_schema.nil?
        err = "no schema defined for #{controller_name}##{action_name}[#{response.code}]"
        return [nil, [err], RuntimeError.new(err)]
      end

      schema = JSON.parse(JSON(unprocessed_schema))

      error_list = JSON::Validator.fully_validate(schema, response.body, :strict => false, :version => :draft4, :json => true)

      error_object = Apipie::ResponseDoesNotMatchSwaggerSchema.new(controller_name, action_name, response.code, error_list, schema, response.body)

      [schema, error_list, error_object]
    rescue Apipie::NoDocumentedMethod
      [nil, [], nil]
    end
  end

  include Apipie::ControllerValidationHelpers
end

module Apipie
  def self.print_validation_errors(validation_errors, schema, response, error_object = nil)
    Rails.logger.warn(validation_errors.to_s)
    if Rails.env.test?
      puts "schema validation errors:"
      validation_errors.each { |e| puts "--> #{e.to_s}" }
      puts "schema:  #{schema.nil? ? '<none>' : JSON(schema)}"
      puts "response: #{response.body}"
      raise error_object if error_object
    end
  end
end

#---------------------------------
# Manual-validation (RSpec matcher)
#---------------------------------
RSpec::Matchers.define :match_declared_responses do
  match do |actual|
    (schema, validation_errors) = subject.send(:schema_validation_errors_for_response)
    valid = (validation_errors == [])
    Apipie::print_validation_errors(validation_errors, schema, response) unless valid

    valid
  end
end


#---------------------------------
# Auto-validation logic
#---------------------------------
module RSpec::Rails::ViewRendering
  # Augment the RSpec DSL
  module ClassMethods
    def auto_validate_rendered_views
      before do
        @is_response_validation_on = true
      end

      after do
        @is_response_validation_on = false
      end
    end
  end
end


ActionController::TestCase::Behavior.instance_eval do
  # instrument the 'process' method in ActionController::TestCase to enable response validation
  module Apipie::ResponseValidationHelpers
    @is_response_validation_on = false
    def process(*, **)
      result = super
      validate_response if @is_response_validation_on

      result
    end

    def validate_response
      controller.send(:validate_response_and_abort_with_info_if_errors)
    end
  end

  prepend Apipie::ResponseValidationHelpers
end


class ActionController::Base
  module Apipie::ControllerValidationHelpers
    def validate_response_and_abort_with_info_if_errors

      (schema, validation_errors, error_object) = schema_validation_errors_for_response

      valid = (validation_errors == [])
      if !valid
        Apipie::print_validation_errors(validation_errors, schema, response, error_object)
      end
    end
  end
end


