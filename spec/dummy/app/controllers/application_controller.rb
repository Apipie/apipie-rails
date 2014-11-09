class ApplicationController < ActionController::Base
  
  before_filter :apipie_validations if ENV['VALIDATE'] == 'explicitly'
  
  resource_description do
    param :oauth, String, :desc => "Authorization", :required => false
  end
end
