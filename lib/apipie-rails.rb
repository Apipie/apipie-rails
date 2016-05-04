require 'i18n'
require 'json'
require 'active_support/hash_with_indifferent_access'

require "apipie/routing"
require "apipie/markup"
require "apipie/apipie_module"
require "apipie/dsl_definition"
require "apipie/configuration"
require "apipie/method_description"
require "apipie/resource_description"
require "apipie/param_description"
require "apipie/errors"
require "apipie/error_description"
require "apipie/see_description"
require "apipie/validator"
require "apipie/railtie"
require 'apipie/extractor'
require "apipie/version"

if Rails.version.start_with?("3.0")
  warn 'Warning: apipie-rails is not going to support Rails 3.0 anymore in future versions'
end
