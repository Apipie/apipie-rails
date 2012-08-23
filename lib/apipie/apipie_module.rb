require "apipie/helpers"
require "apipie/application"

module Apipie
  extend Apipie::Helpers

  def self.app
    @application ||= Apipie::Application.new
  end

  def self.to_json(version = nil, resource_name = nil, method_name = nil)
    version ||= Apipie.configuration.default_version
    app.to_json(version, resource_name, method_name)
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

  def self.debug(message)
    puts message if Apipie.configuration.debug
  end

  # get application description for given or default version
  def self.app_info(version = nil)
    if version && self.configuration.app_info.has_key?(version)
      Apipie.markup_to_html(self.configuration.app_info[version])
    elsif self.configuration.app_info.has_key? Apipie.configuration.default_version
      Apipie.markup_to_html(self.configuration.app_info[Apipie.configuration.default_version])
    else
      "Another API description"
    end
  end

  def self.api_base_url(version = nil)
    if version && self.configuration.api_base_url.has_key?(version)
      self.configuration.api_base_url[version]
    elsif self.configuration.api_base_url.has_key?(Apipie.configuration.default_version)
      self.configuration.api_base_url[Apipie.configuration.default_version]
    else
      "/api"
    end
  end

end
