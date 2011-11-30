module Restapi
  
  class Api
    
    # attr_reader :short_description
    attr_reader :errors, :api_args, :params, :full_description, :method_name
    
    def initialize(method_name, app)
      @method_name = method_name
      @full_description = app.get_description
      @errors = app.get_errors
      @api_args = app.get_api_args
      @params = app.get_params
    end
    
    # Restapi module methods
    class << self
      
      def define_api(method_name)
        Restapi.application.define_api(self, method_name)
      end
      
    end
  end
  
end