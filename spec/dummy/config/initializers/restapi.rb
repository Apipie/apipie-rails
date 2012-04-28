Restapi.configure do |config|
  config.app_name = "Test app"
  config.copyright = "&copy; 2012 Pavel Pokorny"
  config.doc_base_url = "/apidoc"
  config.api_base_url = "/api"
  # config.markup = choose one of:
  #   Restapi::Markup::RDoc.new [default]
  #   Restapi::Markup::Markdown.new
  #   Restapi::Markup::Textile.new
  # or provide another class with to_html(text) instance method
  # config.validate = false
  
  path = File.expand_path(File.dirname(__FILE__)+'/../../../../README.rdoc')
  config.app_info = File.read(path)
end


# integer validator
class Restapi::Validator::IntegerValidator < Restapi::Validator::BaseValidator

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
    "Parameter #{@param_name} expecting to be #{@type.name}, got: #{@error_value.class.name}"
  end

  def description
    "Parameter has to be #{@type}."
  end
end
