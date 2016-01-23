class ApplicationController < ActionController::Base
  before_action :run_validations
  
  resource_description do
    param :oauth, String, :desc => "Authorization", :required => false
  end

  def run_validations
    if Apipie.configuration.validate == :explicitly
      apipie_validations
    end
  end

end
