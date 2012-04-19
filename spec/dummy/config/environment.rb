ENV['RAILS_RELATIVE_URL_ROOT'] = '/relative/path'

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Dummy::Application.initialize!
