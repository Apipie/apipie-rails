require "restapi/helpers"
require "restapi/application"
require "ostruct"
require "erb"

module Restapi
  extend Restapi::Helpers

  def self.app
    @application ||= Restapi::Application.new
  end

  # all calls delegated to Restapi::Application instance
  def self.method_missing(method, *args, &block)
    app.respond_to?(method) ? app.send(method, *args, &block) : super
  end

  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  class Configuration
    attr_accessor :app_name, :app_info, :copyright, :markup_language, :validate, :baseurl

    def initialize
      @markup_language = :rdoc
      @app_name = "Another API"
      @app_info = "Another API description"
      @copyright = nil
      @validate = true
      @baseurl = "/restapi"
    end
  end

end
