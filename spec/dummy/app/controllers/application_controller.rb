class ApplicationController < ActionController::Base
  before_action :run_validations

  resource_description do
    param :oauth, String, desc: 'Authorization', required: false
  end

  def run_validations
    apipie_validations if Apipie.configuration.validate == :explicitly
  end
end
