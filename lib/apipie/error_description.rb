module Apipie

  class ErrorDescription

    attr_reader :code, :description, :metadata

    def self.from_dsl_data(args)
      code_or_options, desc, options = args
      Apipie::ErrorDescription.new(code_or_options,
                                   desc,
                                   options)
    end

    def initialize(code_or_options, desc=nil, options={})
      if code_or_options.is_a? Hash
        code_or_options.symbolize_keys!
        @code = code_or_options[:code]
        @metadata = code_or_options[:meta]
        @description = code_or_options[:desc] || code_or_options[:description]
      else
        @code = code_or_options
        @metadata = options[:meta]
        @description = desc
      end
    end

    def to_json
      {
        :code => code,
        :description => description,
        :metadata => metadata
      }
    end

  end

end
