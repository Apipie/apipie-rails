require 'apipie-rails'

module TestEngine
  class Engine < ::Rails::Engine
    isolate_namespace TestEngine
  end
end
