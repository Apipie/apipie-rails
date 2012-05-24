require "restapi/helpers"
require "restapi/application"

module Restapi
  extend Restapi::Helpers

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
    attr_accessor :app_name, :app_info, :copyright, :markup,
      :validate, :api_base_url, :doc_base_url

    alias_method :validate?, :validate

    # matcher to be used in Dir.glob to find controllers to be reloaded e.g.
    #
    #   "#{Rails.root}/app/controllers/api/*.rb"
    attr_accessor :api_controllers_matcher

    # set to true if you want to reload the controllers at each refresh of the
    # documentation. It requires +:api_controllers_matcher+ to be set to work
    # properly.
    attr_writer :reload_controllers

    def reload_controllers?
      @reload_controllers = Rails.env.development? unless defined? @reload_controllers
      return @reload_controllers && @api_controllers_matcher
    end

    # set to true if you want to use pregenerated documentation cache and avoid
    # generating the documentation on runtime (usefull for production
    # environment).
    # You can generate the cache by running
    #
    #     rake restapi:cache
    attr_accessor :use_cache
    alias_method :use_cache?, :use_cache

    attr_writer :cache_dir

    def cache_dir
      @cache_dir ||= File.join(Rails.root, "public", "restapi-cache")
    end
    
    def app_info
      Restapi.markup_to_html(@app_info)
    end
    
    def initialize
      @markup = Restapi::Markup::RDoc.new
      @app_name = "Another API"
      @app_info = "Another API description"
      @copyright = nil
      @validate = true
      @api_base_url = ""
      @doc_base_url = "/restapi"
    end
  end

end
