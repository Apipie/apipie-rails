module Apipie
  class Railtie < Rails::Railtie
    initializer 'apipie.controller_additions' do
      ActiveSupport.on_load :action_controller do
        extend Apipie::DSL::Base
        extend Apipie::DSL::Common
        extend Apipie::DSL::Action
        extend Apipie::DSL::Param
      end
    end
  end
end
