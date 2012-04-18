module Restapi
  class RestapisController < ActionController::Base
    layout false
    
    def index
      respond_to do |format|
        format.json { render :json => Restapi.to_json(params[:resource], params[:method]) }
        format.html
      end
    end

    protected

    helper_method :restapi_javascript_src
    def restapi_javascript_src(file)
      "#{Restapi.configuration.doc_base_url}/javascripts/#{file}"
    end

    helper_method :restapi_stylesheet_src
    def restapi_stylesheet_src(file)
      "#{Restapi.configuration.doc_base_url}/stylesheets/#{file}"
    end
  end
end
