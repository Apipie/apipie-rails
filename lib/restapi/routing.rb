module Restapi
  module Routing
    module MapperExtensions
      def restapi
        namespace "restapi", :path => Restapi.configuration.doc_base_url do
          get("(:resource)/(:method)" => "restapis#index" )
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.send :include, Restapi::Routing::MapperExtensions
