module Restapi
  module Routing
    module MapperExtensions
      def restapi(route = "/restapi")
        
        Restapi.options.route = route
                
        # user can specify route 'alias'
        # self.resources :restapis, :path => route
        self.get("#{route}/(:resource)" => "restapis#index" )
        
        # we need to use some 'static' route from js so we use /restapi, 
        #it should be always defined
        # self.resources :restapis, :path => "/apidoc"
        
        self.get("/apidoc/(:resource)" => "restapis#index" ) unless route == "/apidoc"
        
      end
    end
  end
end
 
ActionDispatch::Routing::Mapper.send :include, Restapi::Routing::MapperExtensions
