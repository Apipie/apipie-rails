module Restapi
  module Routing
    module MapperExtensions
      def restapi(route = "/apidoc")

        Restapi.configuration.doc_base_url = route

        self.get("#{route}/(:resource)/(:method)" => "restapis#index")

      end
    end
  end
end
 
ActionDispatch::Routing::Mapper.send :include, Restapi::Routing::MapperExtensions
