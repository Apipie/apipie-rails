class RestapisController < ActionController::Base
  layout false
  
  def index
    respond_to do |format|
      format.json { render :json => Restapi.to_json(params[:resource], params[:method]) }
      format.html { render 'index' }
    end
  end
  
end
