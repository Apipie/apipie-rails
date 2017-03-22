require 'i18n'
require 'json'
require 'active_support/hash_with_indifferent_access'

require "apipie/routing"
require "apipie/markup"
require "apipie/apipie_module"
require "apipie/dsl/definition"
require "apipie/configuration"
require "apipie/method_description"
require "apipie/resource_description"
require "apipie/param_description"
require "apipie/errors"
require "apipie/response_description"
require "apipie/see_description"
require "apipie/validator"
require "apipie/railtie"
require 'apipie/extractor'
require "apipie/version"

if Rails.version.start_with?("3.0")
  warn 'Warning: apipie-rails is not going to support Rails 3.0 anymore in future versions'
end

module Apipie

  def self.root
    @root ||= Pathname.new(File.dirname(File.expand_path(File.dirname(__FILE__), '/../')))
  end

end
