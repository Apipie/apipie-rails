module Apipie
  module Routing
    module MapperExtensions
      def apipie
        namespace "apipie", :path => Apipie.configuration.doc_base_url do
          constraints(:version => /[^\/]+/) do
            get("(:version)/(:resource)/(:method)" => "apipies#index", :as => :apipie)
						get ":custom_page" => "apipies#custom_page", as: "apipie_custom_page"
          end
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Apipie::Routing::MapperExtensions
