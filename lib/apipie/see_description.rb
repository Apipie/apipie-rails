module Apipie

  class SeeDescription

    attr_reader :link, :description

    def initialize(args)
      if args.first.is_a? Hash
        args = args.first
      elsif args.count == 2
        if args.last.is_a? Hash
          args = {:link => args.first}.merge(args.last)
        else
          args = {:link => args.first, :description => args.second}
        end
      elsif args.count == 1 && args.first.is_a?(String)
        args = {:link => args.first, :description => args.first}
      else
        raise ArgumentError "ApipieError: Bad use of see method."
      end
      @link = args[:link] || args['link']
      @description = args[:desc] || args[:description] || args['desc'] || args['description']
    end

    def to_json
      {:link => see_url, :description => description}
    end

    def see_url
      method_description = Apipie[@link]
      if method_description.nil?
        raise ArgumentError.new("Method #{@link} referenced in 'see' does not exist.")
      end
      method_description.doc_url
    end

  end

end
