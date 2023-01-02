class Apipie::MethodDescription::Api
  attr_accessor :short_description, :path, :http_method, :from_routes,
    :options, :returns

  def initialize(method, path, desc, options)
    @http_method = method.to_s
    @path = path
    @short_description = desc
    @from_routes = options[:from_routes]
    @options = options
  end
end
