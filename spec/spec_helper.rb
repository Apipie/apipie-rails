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
