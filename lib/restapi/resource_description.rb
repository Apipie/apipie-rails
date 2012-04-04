module Restapi
  
  # Resource description
  # 
  # version - api version (1)
  # description
  # path - relative path (/api/articles)
  # methods - array of keys to Restapi.method_descriptions (array of Restapi::MethodDescription)
  # name - human readable alias of resource (Articles)
  # id - resouce name
  class ResourceDescription
    
    attr_reader :_short_description, :_full_description, :_methods, :_id, :_path, :_version, :_name, :_params
    
    def initialize(resource_name, &block)
      @_methods = []
      @_params = Hash.new

      @_id = resource_name
      @_version = "1"
      @_name = @_id.humanize
      @_full_description = ""
      @_short_description = ""
      @_path = ""
      
      block.arity < 1 ? instance_eval(&block) : block.call(self) if block_given?
    end
    
    def param(param_name, *args, &block)
      @_params[param_name] = Restapi::ParamDescription.new(param_name, *args, &block)
    end
    
    def path(path); @_path = path; end
    def version(version); @_version = version; end
    def name(name); @_name = name; end
    def short(short); @_short_description = short; end
    alias :short_description :short
    def desc(description)
      description ||= ''
      @_full_description = Restapi.rdoc.convert(description.strip_heredoc)
    end
    alias :description :desc
    alias :full_description :desc
    
    # add description of resource method
    def add_method(mapi_key)
      @_methods << mapi_key
      @_methods.uniq!
    end
    
    def to_json
      methods = []
      @_methods.each { |key| methods << Restapi.method_descriptions[key].to_json }
      {
        :id => @_id,
        :name => @_name,
        :version => @_version,
        :short_description => @_short_description,
        :full_description => @_full_description,
        
        :methods => methods,
        :params => @_params.collect { |_,v| v.to_json }
      }
    end

  end
  
end