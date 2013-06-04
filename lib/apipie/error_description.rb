module Apipie

  class ErrorDescription

    attr_reader :code, :description, :label

    def initialize(args)
      if args.first.is_a? Hash
        args = args.first
      elsif args.count == 2
        args = {:code => args.first, :description => args.second}
      else
        raise ArgumentError "ApipieError: Bad use of error method."
      end
      @code = args[:code] || args['code']
      @description = args[:desc] || args[:description] || args['desc'] || args['description']
      @label = get_label
    end

    def to_json
      {:code => code, :description => description, :label => label}
    end

    private
    
    def get_label
      case @code
        when 200
          'label label-info'
        when 201
          'label label-success'
        when 204
          'label label-info2'
        when 401
          'label label-warning'
        when 403
          'label label-warning2'
        when 422
          'label label-important'
        when 404
          'label label-inverse'
        else
          'label'
      end
    end

  end

end
