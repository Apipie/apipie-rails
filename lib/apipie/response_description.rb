module Apipie

  class ResponseDescription

    attr_reader :code, :body, :metadata, :headers

    def self.from_dsl_data(args)
      code_or_options, desc, options = args
      Apipie::ResponseDescription.new(code_or_options,
                                   desc,
                                   options)
    end

    def initialize(code, body=nil, options={})
      if !code.is_a? Numeric
        warn "First argument must be a response code (Integer)"
      else
        options.symbolize_keys!
        @headers = options[:headers]
        @body = body
        @code = code
        @metadata = options[:meta]
      end
    end

    def to_json
      {
        :code => code,
        :headers => headers,
        :body => body,
        :metadata => metadata
      }
    end

  end

end
