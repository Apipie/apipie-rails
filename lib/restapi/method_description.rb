module Restapi

  class MethodDescription
  
    class Api
      
      attr_accessor :short_description, :api_url, :http_method
      
      def initialize(args)
        @http_method = args[:method] || args[:http_method] || args[:http]
        @short_description = args[:desc] || args[:short] || args[:description]
        @api_url = create_api_url(args[:path] || args[:url])
      end
      
      private
      
      def create_api_url(path)
        "#{Restapi.configuration.api_base_url}#{path}"
      end

    end

    attr_reader :errors, :params, :full_description, :method, :resource, :apis
    
    def initialize(method, resource, app)
      @method = method
      @resource = resource
      
      @apis = app.get_api_args
     
      desc = app.get_description || ''
      @full_description = Restapi.markup_to_html(desc)
      @errors = app.get_errors
      @params = app.get_params

      parent = @resource.camelize.sub(/$/,'Controller').constantize.superclass
      if parent != ActionController::Base
        @parent_resource = parent.controller_name
      end
    end

    def params
      all_params = Hash.new

      # get params from parent resource description
      if @parent_resource
        parent = Restapi.get_resource_description(@parent_resource)
        all_params = parent._params if parent
      end

      # get params from actual resource description
      if @resource
        resource = Restapi.get_resource_description(@resource)
        all_params = all_params.merge(resource._params) if resource
      end

      # get params from actual method description
      all_params.merge(@params).reject { |_, v| v.validator.nil? }
    end
    
    def doc_url
      [
        ENV["RAILS_RELATIVE_URL_ROOT"],
        Restapi.configuration.doc_base_url,
        "##{@resource}/#{@method}"
      ].join
    end

    def method_apis_to_json
      @apis.each.collect do |api|
        {
          :api_url => api.api_url,
          :http_method => api.http_method,
          :short_description => api.short_description
        }
      end
    end

    def to_json
      {
        :doc_url => doc_url,
        :name => @method,
        :apis => method_apis_to_json,
        :full_description => @full_description,
        :errors => @errors,
        :params => params.collect { |_,v| v.to_json }.flatten
      }
    end

  end
  
end
