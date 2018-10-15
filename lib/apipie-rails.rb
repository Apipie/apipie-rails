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
require "apipie/response_description"
require "apipie/response_description_adapter"
require "apipie/see_description"
require "apipie/tag_list_description"
require "apipie/validator"
require "apipie/railtie"
require 'apipie/extractor'
require "apipie/version"
require "apipie/swagger_generator"

if Rails.version.start_with?("3.0")
  warn 'Warning: apipie-rails is not going to support Rails 3.0 anymore in future versions'
end
