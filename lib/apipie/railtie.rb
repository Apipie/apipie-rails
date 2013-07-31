module Apipie
  class Railtie < Rails::Railtie
    initializer 'apipie.controller_additions' do
      ActiveSupport.on_load :action_controller do
        extend Apipie::DSL::Controller
      end
    end
  end
end
