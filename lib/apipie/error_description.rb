module Apipie

  class ErrorDescription

    attr_reader :code, :description, :metadata, :label

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
      @label = get_label
    end

    def to_json
      {
        :code => code,
        :description => description,
        :metadata => metadata,
        :label => label
      }
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
