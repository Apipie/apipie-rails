module Restapi
  
  class MethodDescription
    
    attr_reader :errors, :params, :full_description, :method, :resource, :short_description, :path, :http
    
    def initialize(method, resource, app)
      @method = method
      @resource = resource
      args = app.get_api_args
      @short_description = args[:desc] || args[:short] || args[:description]
      @path = args[:path]
      @http = args[:method]
      desc = app.get_description || ''
      @full_description = Restapi.rdoc.convert(desc.strip_heredoc)
      @errors = app.get_errors
      @params = app.get_params
    end
    
    def doc_url; "#{Restapi.configuration.doc_base_url}/#{@resource}/#{@method}"; end
    def api_url; "#{Restapi.configuration.api_base_url}#{@path}"; end

    def to_json
      {
        :doc_url => doc_url,
        :api_url => api_url,
        :name => @method,
        :http_method => @http,
        :short_description => @short_description,
        :full_description => @full_description,
        :errors => @errors,
        :params => @params.collect { |_,v| v.to_json }
      }
    end

  end
  
end