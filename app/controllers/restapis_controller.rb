class RestapisController < ActionController::Base
  layout false
  
  def index

    respond_to do |format|
      
      format.json do
        # return methods description if resource given
        if params[:resource].present?

          # return app info
          if params[:resource] == "api_info"

            render :json => Restapi.info

          else

            keys = Restapi.resource_descriptions[params[:resource]]
            render(:nothing => true) and return unless keys
            keys = keys.methods
            render(:nothing => true) and return unless keys
            methods = []
            keys.each { |key| methods << Restapi.method_descriptions[key].to_json }
            render :json => methods

          end
        # return all resources if no resource given
        else
          render :json => Restapi.resource_descriptions.collect{ |_, v| v }
        end

      end
      
      # render 
      format.html { render 'index' }
    end
  end
  
end
