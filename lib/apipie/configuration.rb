module Apipie
  class Configuration

    attr_accessor :app_name, :app_info, :copyright, :markup, :disqus_shortname,
      :api_base_url, :doc_base_url, :required_by_default, :layout,
      :default_version, :debug, :version_in_url, :namespaced_resources,
      :validate, :validate_value, :validate_presence, :validate_key, :authenticate, :doc_path,
      :show_all_examples, :process_params, :update_checksum, :checksum_path,
      :link_extension, :record, :languages, :translate, :locale, :default_locale,
      :persist_show_in_doc, :authorize

    alias_method :validate?, :validate
    alias_method :required_by_default?, :required_by_default
    alias_method :namespaced_resources?, :namespaced_resources

    # matcher to be used in Dir.glob to find controllers to be reloaded e.g.
    #
    #   "#{Rails.root}/app/controllers/api/*.rb"
    attr_accessor :api_controllers_matcher

    # set to true if you want to reload the controllers at each refresh of the
    # documentation. It requires +:api_controllers_matcher+ to be set to work
    # properly.
    attr_writer :reload_controllers

    # specify routes if used router differ from default e.g.
    #
    # Api::Engine.routes
    attr_accessor :api_routes

    # a object responsible for transforming the routes loaded from Rails to a form
    # to be used in the documentation, when using the `api!` keyword. By default,
    # it's Apipie::RoutesFormatter. To customize the behaviour, one can inherit from
    # from this class and override the methods as needed.
    attr_accessor :routes_formatter

    def reload_controllers?
      @reload_controllers = Rails.env.development? unless defined? @reload_controllers
      return @reload_controllers && @api_controllers_matcher
    end

    def validate_value
      return (validate? && @validate_value)
    end
    alias_method :validate_value?, :validate_value

    def validate_presence
      return (validate? && @validate_presence)
    end
    alias_method :validate_presence?, :validate_presence

    def validate_key
      return (validate? && @validate_key)
    end
    alias_method :validate_key?, :validate_key

    def process_value?
      @process_params
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

    # Persist the show_in_doc value in the examples if true. Use this if you
    # cannot set the flag in the tests themselves (no rspec for example).
    attr_writer :persist_show_in_doc

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

    def api_routes
      @api_routes || Rails.application.routes
    end

    def initialize
      @markup = Apipie::Markup::RDoc.new
      @app_name = "Another API"
      @app_info = HashWithIndifferentAccess.new
      @copyright = nil
      @validate = :implicitly
      @validate_value = true
      @validate_presence = true
      @validate_key = false
      @required_by_default = false
      @api_base_url = HashWithIndifferentAccess.new
      @doc_base_url = "/apipie"
      @layout = "apipie/apipie"
      @disqus_shortname = nil
      @default_version = "1.0"
      @debug = false
      @version_in_url = true
      @namespaced_resources = false
      @doc_path = "doc"
      @process_params = false
      @checksum_path = [@doc_base_url, '/api/']
      @update_checksum = false
      @link_extension = ".html"
      @record = false
      @languages = []
      @default_locale = 'en'
      @locale = lambda { |locale| @default_locale }
      @translate = lambda { |str, locale| str }
      @persist_show_in_doc = false
      @routes_formatter = RoutesFormatter.new
    end
  end
end
