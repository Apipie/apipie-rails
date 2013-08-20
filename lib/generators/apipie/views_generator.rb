module Apipie
  class ViewsGenerator < ::Rails::Generators::Base
    source_root File.expand_path("../../../../app/views", __FILE__)
    desc 'Copy Apipie views to your application'

    def copy_views
      directory 'apipie', 'app/views/apipie'
      directory 'layouts/apipie', 'app/views/layouts/apipie'
    end
  end
end
