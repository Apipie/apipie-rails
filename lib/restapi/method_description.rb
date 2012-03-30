module Restapi
  
  class MethodDescription
    
    attr_reader :errors, :params, :full_description, :method, :resource, :short_description, :path, :http
    
    def initialize(method, resource, app)
      @method = method
      @resource = resource
      args = app.get_api_args
      @short_description = args[:desc]
      @path = args[:path]
      @http = args[:method]
      desc = app.get_description || ''
      @full_description = Restapi.rdoc.convert(desc.strip_heredoc)
      @errors = app.get_errors
      @params = app.get_params
    end

    def to_json
      puts "#{@method} to_json"
      {
        :id => "#{@resource}##{@method}",
        :method => @method,
        :resource => @resource,
        :short_description => @short_description,
        :path => @path,
        :http => @http,
        :full_description => @full_description,
        :errors => @errors,
        :params => @params.collect { |_,v| v.to_json }
      }
    end

  end
  
end