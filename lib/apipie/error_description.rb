module Apipie

  class ErrorDescription
    attr_reader :code, :description, :metadata

    def self.from_dsl_data(args)
      code_or_options, desc, options = args
      Apipie::ErrorDescription.new(code_or_options, desc, options)
    end

    def initialize(code_or_options, desc = nil, options = {})
      if code_or_options.is_a? Hash
        code_or_options.symbolize_keys!
        @code = code_or_options[:code]
        @metadata = code_or_options[:meta]
        @description = code_or_options[:desc] || code_or_options[:description]
      else
        @code =
          if code_or_options.is_a? Symbol
            begin
              Rack::Utils.status_code(code_or_options)
            rescue ArgumentError
              nil
            end
          else
            code_or_options
          end

        raise UnknownCode, code_or_options unless @code

        @metadata = options[:meta]
        @description = desc
      end
    end

    def to_json(lang)
      {
        :code => code,
        :description => Apipie.app.translate(description, lang),
        :metadata => metadata
      }
    end

  end

end
