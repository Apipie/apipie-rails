Apipie.configure do |config|
  config.app_name = "Test app"
  config.copyright = "&copy; 2012 Pavel Pokorny"

  # set default API version
  # can be overriden in resource_description
  # by default is it 1.0 if not specified anywhere
  # this must be defined before api_base_url and app_info
  config.default_version = "development"

  config.doc_base_url = "/apidoc"

  # default version base url
  # to define base url for specifid version use
  # config.api_base_url[version] = url
  # or define it in your base controller
  config.api_base_url = "/api"

  # set to true to turn on/off the cache. To generate the cache use:
  #
  #     rake apipie:cache
  #
  config.use_cache = Rails.env.production?
  # config.cache_dir = File.join(Rails.root, "public", "apipie-cache") # optional

  # set to enable/disable reloading controllers (and the documentation with it),
  # by default enabled in development
  # config.reload_controllers = false

  # for reloading to work properly you need to specify where your api controllers are (like in Dir.glob):
  config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "**","*.rb")

  # config.markup = choose one of:
  #   Apipie::Markup::RDoc.new [default]
  #   Apipie::Markup::Markdown.new
  #   Apipie::Markup::Textile.new
  # or provide another class with to_html(text) instance method
  # to disable markup, use
  # config.markup = nil

  # config.validate = false

  # set all parameters as required by default
  # if enabled, use param :name, val, :required => false for optional params
  config.required_by_default = false

  # set default version info, to describe specific version use
  # config.app_info[version] = description
  # or put this in your base or application controller
  config.app_info = "Dummy app for testing"

  # show debug informations
  config.debug = false

  # set all parameters as required by default
  # if enabled, use param :name, val, :required => false for optional params
  config.required_by_default = false

  # use custom layout
  # use Apipie.include_stylesheets and Apipie.include_javascripts
  # to include apipies css and js
  config.layout = "application"

  # specify disqus site shortname to show discusion on each page
  # to show it in custom layout, use `render 'disqus' if Apipie.configuration.use_disqus?`
  # config.disqus_shortname = 'paveltest'
end


# integer validator
class Apipie::Validator::IntegerValidator < Apipie::Validator::BaseValidator

  def initialize(param_description, argument)
    super(param_description)
    @type = argument
  end

  def validate(value)
    return false if value.nil?
    !!(value.to_s =~ /^[-+]?[0-9]+$/)
  end

  def self.build(param_description, argument, options, block)
    if argument == Integer || argument == Fixnum
      self.new(param_description, argument)
    end
  end

  def error
    # Newer style is to return an instance of ParamInvalid.  Keeping this
    # to test backwards compatibility.
    "Parameter #{param_name} expecting to be #{@type.name}, got: #{@error_value.class.name}"
  end

  def description
    "Parameter has to be #{@type}."
  end

  def expected_type
    'numeric'
  end
end
