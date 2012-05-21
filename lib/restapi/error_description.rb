module Restapi

  class ErrorDescription

    attr_reader :code, :description

    def initialize(args)
      if args.first.is_a? Hash
        args = args.first
      elsif args.count == 2
        args = {:code => args.first, :description => args.second}
      else
        raise ArgumentError "RestapiError: Bad use of error method."
      end
      @code = args[:code] || args['code']
      @description = args[:desc] || args[:description] || args['desc'] || args['description']
    end

  end

end