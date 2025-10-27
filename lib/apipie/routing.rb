module Apipie
  module Routing
    module MapperExtensions
      def apipie(options = {})
        namespace "apipie", :path => Apipie.configuration.doc_base_url do
          get 'apipie_checksum', :to => "apipies#apipie_checksum", :format => "json"
          constraints(:version => %r{[^/]+}, :resource => %r{[^/]+}, :method => %r{[^/]+}) do
            get_args = options.reverse_merge("(:version)/(:resource)/(:method)" => "apipies#index", :as => :apipie)

            Rails.version >= "5.2" ? get(**get_args) : get(get_args)
          end
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Apipie::Routing::MapperExtensions
