Apipie.configure do |config|
  config.app_name = "Test app"
  config.copyright = "&copy; 2012 Pavel Pokorny"
  config.doc_base_url = "/apidoc"
  config.api_base_url = "/api"

  # set to true to turn on/off the cache. To generate the cache use:
  #
  #     rake apipie:cache
  #
  # config.use_cache = Rails.env.production?
  # config.cache_dir = File.join(Rails.root, "public", "apipie-cache") # optional

  # set to enable/disable reloading controllers (and the documentation with it),
  # by default enabled in development
  # config.reload_controllers = false

  # for reloading to work properly you need to specify where your api controllers are (like in Dir.glob):
  config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "**","*.rb")

  # config.api_base_url = "/api"
  # config.markup = choose one of:
  #   Apipie::Markup::RDoc.new [default]
  #   Apipie::Markup::Markdown.new
  #   Apipie::Markup::Textile.new
  # or provide another class with to_html(text) instance method
  # config.validate = false

  path = File.expand_path(File.dirname(__FILE__)+'/../../../../README.rdoc')
  config.app_info = File.read(path)

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
