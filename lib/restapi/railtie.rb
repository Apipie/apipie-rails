module Restapi
  class Railtie < Rails::Railtie
    initializer 'restapi.controller_additions' do
      ActiveSupport.on_load :action_controller do
        extend Restapi::DSL
      end
    end
  end
end
