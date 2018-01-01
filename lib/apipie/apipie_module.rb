require "apipie/helpers"
require "apipie/application"

module Apipie
  extend Apipie::Helpers

  def self.app
    @application ||= Apipie::Application.new
  end

  def self.to_json(version = nil, resource_name = nil, method_name = nil, lang = nil)
    version ||= Apipie.configuration.default_version
    app.to_json(version, resource_name, method_name, lang)
  end

  def self.to_swagger_json(version = nil, resource_name = nil, method_name = nil, lang = nil, clear_warnings=true)
    version ||= Apipie.configuration.default_version
    app.to_swagger_json(version, resource_name, method_name, lang, clear_warnings)
  end

  def self.json_schema_for_method_response(controller_name, method_name, return_code, allow_nulls)
    # note: this does not support versions (only the default version is queried)!
    version ||= Apipie.configuration.default_version
    app.json_schema_for_method_response(version, controller_name, method_name, return_code, allow_nulls)
  end

  def self.json_schema_for_self_describing_class(cls, allow_nulls=true)
    app.json_schema_for_self_describing_class(cls, allow_nulls)
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
  def self.app_info(version = nil, lang = nil)
    info = if app_info_version_valid? version
      translate(self.configuration.app_info[version], lang)
    elsif app_info_version_valid? Apipie.configuration.default_version
      translate(self.configuration.app_info[Apipie.configuration.default_version], lang)
    else
      "Another API description"
    end

    Apipie.markup_to_html info
  end

  def self.api_base_url(version = nil)
    if api_base_url_version_valid? version
      self.configuration.api_base_url[version]
    elsif api_base_url_version_valid? Apipie.configuration.default_version
      self.configuration.api_base_url[Apipie.configuration.default_version]
    else
      "/api"
    end
  end

  def self.app_info_version_valid?(version)
    version && self.configuration.app_info.has_key?(version)
  end

  def self.api_base_url_version_valid?(version)
    version && self.configuration.api_base_url.has_key?(version)
  end

  def self.record(record)
    Apipie::Extractor.start record
  end
end
