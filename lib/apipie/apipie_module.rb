require "apipie/helpers"
require "apipie/application"
require "apipie/configuration"

module Apipie
  extend Apipie::Helpers

  def self.app
    @application ||= Apipie::Application.new
  end

  def self.to_json(resource_name = nil, method_name = nil)
    app.to_json(resource_name, method_name)
  end

  # all calls delegated to Apipie::Application instance
  def self.method_missing(method, *args, &block)
    app.respond_to?(method) ? app.send(method, *args, &block) : super
  end

  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

end
