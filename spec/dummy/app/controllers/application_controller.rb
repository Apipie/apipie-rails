class ApplicationController < ActionController::Base
  
  resource_description do
    param :oauth, String, :desc => "Authorization", :required => false
  end
end
