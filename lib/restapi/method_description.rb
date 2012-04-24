require 'set'
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

    attr_reader :errors, :full_description, :method, :resource, :apis
    
    def initialize(method, resource, app)
      @method = method
      @resource = resource
      
      @apis = app.get_api_args
     
      desc = app.get_description || ''
      @full_description = Restapi.markup_to_html(desc)
      @errors = app.get_errors
      @params_ordered = app.get_params

      parent = @resource.camelize.sub(/$/,'Controller').constantize.superclass
      if parent != ActionController::Base
        @parent_resource = parent.controller_name
      end
    end

    def params
      params_ordered.reduce({}) { |h,p| h[p.name] = p; h }
    end

    def params_ordered
      all_params = []
      # get params from parent resource description
      if @parent_resource
        parent = Restapi.get_resource_description(@parent_resource)
        merge_params(all_params, parent._params_ordered) if parent
      end

      # get params from actual resource description
      if @resource
        resource = Restapi.get_resource_description(@resource)
        merge_params(all_params, resource._params_ordered) if resource
      end

      merge_params(all_params, @params_ordered)
      all_params.find_all(&:validator)
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
        :params => params_ordered.map(&:to_json).flatten
      }
    end

    private

    def merge_params(params, new_params)
      new_param_names = Set.new(new_params.map(&:name))
      params.delete_if { |p| new_param_names.include?(p.name) }
      params.concat(new_params)
    end

  end
  
end
