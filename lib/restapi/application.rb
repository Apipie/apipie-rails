require "restapi/api_manager"

module Restapi
  
  class Application
    
    include ApiManager
    
    def initialize
      puts "initialize Restapi"
      super
    end
    
    def options
      @options ||= OpenStruct.new
    end
    
  end
  
end