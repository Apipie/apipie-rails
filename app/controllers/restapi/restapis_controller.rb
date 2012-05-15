module Restapi
  class RestapisController < ActionController::Base
    layout 'restapi/restapi'
    
    def index
      respond_to do |format|
       
        Restapi.reload_documentation if Restapi.configuration.reload_controllers?
        @doc = Restapi.to_json(params[:resource], params[:method])

        format.json do
          render :json => @doc
        end

        format.html do

          @doc = @doc[:docs]
          if params[:resource].present? && params[:method].present?
            @resource = @doc[:resources].first
            @method = @resource[:methods].first
            render 'method'
          elsif params[:resource].present?
            @resource = @doc[:resources].first
            render 'resource'
          else
            render 'index'
          end
        end
      end
    end

  end
end
