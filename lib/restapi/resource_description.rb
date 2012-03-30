module Restapi
  
  # Resource description
  # 
  # version - api version (1)
  # description
  # path - relative path (/api/articles)
  # methods - array of keys to Restapi.method_descriptions (array of Restapi::MethodDescription)
  # alias - human readable alias of resource (Articles)
  # id - resouce name
  class ResourceDescription
    
    attr_reader :version, :description, :path, :methods, :alias, :id
    
    def initialize(resource_name, app)
      @methods = []

      @id = resource_name
      args = app.get_api_args
      @version = args[:version] || "1"
      @alias = args[:alias] || @id.humanize
      # @description = Restapi.rdoc.convert(args[:desc]||"")
      @description = args[:desc]
      @path = args[:path]
    end

    def add_method(mapi_key)
      @methods << mapi_key
      @methods.uniq!
    end

  end
  
end