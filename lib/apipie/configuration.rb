module Apipie
  class Configuration

    attr_accessor :app_name, :app_info, :copyright, :markup, :disqus_shortname,
      :validate, :api_base_url, :doc_base_url, :required_by_default, :layout,
      :default_version, :debug, :version_in_url

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

    # array of controller names (strings) (might include actions as well)
    # to be ignored # when generationg the documentation
    # e.g. %w[Api::CommentsController Api::PostsController#post]
    attr_writer :ignored
    def ignored
      @ignored ||= []
      @ignored.map(&:to_s)
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

    # set app description for default version
    # to maintain backward compatibility
    # new way: config.app_info[version] = description
    def app_info=(description)
      version = Apipie.configuration.default_version
      @app_info[version] = description
    end

    # set base url for default version of API
    # to set it for specific version use
    # config.api_base_url[version] = url
    def api_base_url=(url)
      version = Apipie.configuration.default_version
      @api_base_url[version] = url
    end

    def initialize
      @markup = Apipie::Markup::RDoc.new
      @app_name = "Another API"
      @app_info = HashWithIndifferentAccess.new
      @copyright = nil
      @validate = true
      @required_by_default = false
      @api_base_url = HashWithIndifferentAccess.new
      @doc_base_url = "/apipie"
      @layout = "apipie/apipie"
      @disqus_shortname = nil
      @default_version = "1.0"
      @debug = false
      @version_in_url = true
    end
  end
end
