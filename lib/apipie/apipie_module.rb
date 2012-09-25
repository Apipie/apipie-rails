require "apipie/helpers"
require "apipie/application"

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

  class Configuration
    attr_accessor :app_name, :app_info, :copyright, :markup, :disqus_shortname,
      :validate, :api_base_url, :doc_base_url, :required_by_default, :layout

    alias_method :validate?, :validate
    alias_method :required_by_default?, :required_by_default

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
    #     rake apipie:cache
    attr_accessor :use_cache
    alias_method :use_cache?, :use_cache

    attr_writer :cache_dir
    def cache_dir
      @cache_dir ||= File.join(Rails.root, "public", "apipie-cache")
    end

    # if there is not obvious reason why the DSL should be turned on (no
    # validations, cache turned on etc.), it's disabled to avoid unneeded
    # allocation. It you need the DSL for other reasons, you can force the
    # activation.
    attr_writer :force_dsl
    def force_dsl?
      @force_dsl
    end

    # array of controller names (strings) (might include actions as well)
    # to be ignored # when extracting description form calls.
    # e.g. %w[Api::CommentsController Api::PostsController#post]
    attr_writer :ignored_by_recorder
    def ignored_by_recorder
      @ignored_by_recorder ||= []
      @ignored_by_recorder.map(&:to_s)
    end

    # comment to put before docs that was generated automatically. It's used to
    # determine if the description should be overwritten next recording.
    # If you want to keep the documentation (prevent from overriding), remove
    # the line above the docs.
    attr_writer :generated_doc_disclaimer
    def generated_doc_disclaimer
      @generated_doc_disclaimer ||= "# DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME"
    end

    def use_disqus?
      !@disqus_shortname.blank?
    end

    def app_info
      Apipie.markup_to_html(@app_info)
    end

    def initialize
      @markup = Apipie::Markup::RDoc.new
      @app_name = "Another API"
      @app_info = "Another API description"
      @copyright = nil
      @validate = true
      @required_by_default = false
      @api_base_url = ""
      @doc_base_url = "/apipie"
      @layout = "apipie/apipie"
      @disqus_shortname = nil
    end
  end

end
