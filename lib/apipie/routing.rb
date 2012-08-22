module Apipie
  module Routing
    module MapperExtensions
      def apipie
        namespace "apipie", :path => Apipie.configuration.doc_base_url do
          get("(:resource)/(:method)" => "apipies#index" )
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Apipie::Routing::MapperExtensions
