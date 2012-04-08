require "restapi/application"
require "ostruct"
require "erb"

module Restapi

  def self.rdoc
    @rdoc ||= RDoc::Markup::ToHtml.new
  end
  
  def self.convert_markup(text)
    Restapi.rdoc.convert(text.strip_heredoc)
  end

  def self.app
    @application ||= Restapi::Application.new
  end
  
  def self.to_json(resource_name = nil, method_name = nil)
    app.to_json(resource_name, method_name)
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
    attr_accessor :app_name, :app_info, :copyright, :markup_language, :validate, :api_base_url, :doc_base_url

    def app_info=(text)
      @app_info = Restapi.convert_markup(text)
    end
    
    def initialize
      @markup_language = :rdoc
      @app_name = "Another API"
      @app_info = "Another API description"
      @copyright = nil
      @validate = true
      @api_base_url = ""
      @doc_base_url = "/apidoc"
    end
  end

end
