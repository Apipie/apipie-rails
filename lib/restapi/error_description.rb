module Restapi

  class ErrorDescription

    attr_reader :code, :description
    
    def initialize(args)
      args ||= []
      @code = args[:code] || args['code']
      @description = args[:desc] || args[:description] || args['desc'] || args['description']
    end

  end

end