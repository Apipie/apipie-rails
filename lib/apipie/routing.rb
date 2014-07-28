module Apipie
  module Routing
    module MapperExtensions
      def apipie(options = {})
        namespace "apipie", :path => Apipie.configuration.doc_base_url do
          get 'apipie_checksum', :to => "apipies#apipie_checksum", :format => "json"
          constraints(:version => /[^\/]+/, :resource => /[^\/]+/, :method => /[^\/]+/) do
            get(options.reverse_merge("(:version)/(:resource)/(:method)" => "apipies#index", :as => :apipie))
          end
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Apipie::Routing::MapperExtensions
