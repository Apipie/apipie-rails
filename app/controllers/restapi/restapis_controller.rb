module Restapi
  class RestapisController < ActionController::Base
    layout false
    
    def index
      respond_to do |format|
        format.json do
          render :json => Restapi.to_json(params[:resource], params[:method])
        end
        format.html do
          if Rails.env.development?
            Dir[File.join(Rails.root, "app", "controllers", "**","*")].each {|f| load f}
          end
        end
      end
    end

  end
end
