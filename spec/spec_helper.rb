require 'rubygems'
require 'bundler/setup'

ENV["RAILS_ENV"] ||= 'test'
APIPIE_ROOT = File.expand_path('../..', __FILE__)
require File.expand_path("../dummy/config/environment", __FILE__)

require 'rspec/rails'

require 'apipie-rails'

module Rails4Compatibility
  module Testing
    def process(*args)
      compatible_request(*args) { |*new_args| super(*new_args) }
    end

    def compatible_request(method, action, hash = {})
      if hash.is_a?(Hash)
        if Gem::Version.new(Rails.version) < Gem::Version.new('5.0.0')
          hash = hash.dup
          hash.merge!(hash.delete(:params) || {})
        elsif hash.key?(:params)
          hash = { :params => hash }
        end
      end
      if hash.empty?
        yield method, action
      else
        yield method, action, hash
      end
    end
  end
end


#
# Matcher to validate the hierarchy of fields described in an internal 'returns' object (without checking their type)
#
# For example, code such as:
#           returns_obj = Apipie.get_resource_description(...)._methods.returns.detect{|e| e.code=200})
#           expect(returns_obj).to match_param_structure([:pet_name, :animal_type, :pet_measurements => [:weight, :height]])
#
# will verify that the payload structure described for the response of return code 200 is:
#           {
#             "pet_name": <any>,
#             "animal_type": <any>,
#             "pet_measurements": {
#                 "weight": <any>,
#                 "height": <any>
#             }
#           }
#
#
RSpec::Matchers.define :match_field_structure do |expected|
  @last_message = nil

  match do |actual|
    deep_match?(actual, expected)
  end

  def deep_match?(actual, expected, breadcrumb=[])
    num = 0
    for pdesc in expected do
      if pdesc.is_a? Symbol
        return false unless fields_match?(actual.params_ordered[num], pdesc, breadcrumb)
      elsif pdesc.is_a? Hash
        return false unless fields_match?(actual.params_ordered[num], pdesc.keys[0], breadcrumb)
        return false unless deep_match?(actual.params_ordered[num].validator, pdesc.values[0], breadcrumb + [pdesc.keys[0]])
      end
      num+=1
    end
    @fail_message = "expected property count#{breadcrumb == [] ? '' : ' of ' + (breadcrumb).join('.')} (#{actual.params_ordered.count}) to be #{num}"
    actual.params_ordered.count == num
  end

  def fields_match?(param, expected_name, breadcrumb)
    return false unless have_field?(param, expected_name, breadcrumb)
    @fail_message = "expected #{(breadcrumb + [param.name]).join('.')} to eq #{(breadcrumb + [expected_name]).join('.')}"
    param.name.to_s == expected_name.to_s
  end

  def have_field?(field, expected_name, breadcrumb)
    @fail_message = "expected property #{(breadcrumb+[expected_name]).join('.')}"
    !field.nil?
  end

  failure_message do |actual|
    @fail_message
  end
end



#
# Matcher to validate the properties (name, type and options) of a single field in the
# internal representation of a swagger schema
#
# For example, code such as:
#       schema = swagger[:paths][<path>][<method>][:responses][<code>][:schema]
#       expect(schema).to have_field(:pet_name, 'string', {:required => false})
#
# will verify that the selected response schema includes a required string field called 'pet_name'
#
RSpec::Matchers.define :have_field do |name, type, opts={}|
  def fail(msg)
    @fail_message = msg
    false
  end

  @fail_message = ""

  failure_message do |actual|
    @fail_message
  end

  match do |actual|
    return fail("expected schema to have type 'object' (got '#{actual[:type]}')") if (actual[:type]) != 'object'
    return fail("expected schema to include param named '#{name}' (got #{actual[:properties].keys})") if (prop = actual[:properties][name]).nil?
    return fail("expected param '#{name}' to have type '#{type}' (got '#{prop[:type]}')") if prop[:type] != type
    return fail("expected param '#{name}' to have description '#{opts[:description]}' (got '#{prop[:description]}')") if opts[:description] && prop[:description] != opts[:description]
    return fail("expected param '#{name}' to have enum '#{opts[:enum]}' (got #{prop[:enum]})") if opts[:enum] && prop[:enum] != opts[:enum]
    if !opts.include?(:required) || opts[:required] == true
      return fail("expected param '#{name}' to be required") unless actual[:required].include?(name)
    else
      return fail("expected param '#{name}' to be optional") if actual[:required].include?(name)
    end
    true
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("../support/**/*.rb", __FILE__)].each {|f| require f}

RSpec.configure do |config|

  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end

require 'action_controller/test_case.rb'
ActionController::TestCase::Behavior.send(:prepend, Rails4Compatibility::Testing)
