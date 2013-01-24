module Apipie
  class InstallGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../templates", __FILE__)

    class_option(:route,
                 :aliases => "-r",
                 :type => :string,
                 :desc => "What path should be the doc available on",
                 :default => "/apipie")

    def create_initializer
      template 'initializer.rb.erb', 'config/initializers/apipie.rb'
    end

    def add_route
      route("apipie")
    end
  end
end
