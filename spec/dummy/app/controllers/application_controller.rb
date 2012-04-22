class ApplicationController < ActionController::Base
  
  resource_description do
    param :oauth, String, :desc => "Authorization", :required => false
  end

  protect_from_forgery
end
