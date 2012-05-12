module Restapi
  class RestapisController < ActionController::Base
    layout 'restapi/restapi'
    
    def index
      respond_to do |format|

        @doc = Restapi.to_json(params[:resource], params[:method])

        if (@doc[:docs][:resources].blank? || @doc[:docs][:resources].first == 'null') && Rails.env.development?
          Dir[File.join(Rails.root, "app", "controllers", "**","*.rb")].each {|f| load f}
          @doc = Restapi.to_json(params[:resource], params[:method])
        end

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
