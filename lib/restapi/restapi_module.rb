require 'restapi/application'

module Restapi

  # Restapi module singleton methods.
  class << self
    # Current Restapi Application
    def application
      @application ||= Restapi::Application.new
    end

    # Set the current Restapi application object.
    def application=(app)
      @application = app
    end
  end

end
