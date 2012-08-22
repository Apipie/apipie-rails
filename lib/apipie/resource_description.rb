module Apipie

  # Resource description
  #
  # version - api version (1)
  # description
  # path - relative path (/api/articles)
  # methods - array of keys to Apipie.method_descriptions (array of Apipie::MethodDescription)
  # name - human readable alias of resource (Articles)
  # id - resouce name
  # formats - acceptable request/response format types
  class ResourceDescription

    attr_reader :controller, :_short_description, :_full_description, :_methods, :_id,
      :_path, :_version, :_name, :_params_ordered, :_errors_ordered, :_formats

    def initialize(controller, resource_name, &block)
      @_methods = []
      @_params_ordered = []
      @_errors_ordered = []

      @controller = controller
      @_id = resource_name
      @_version = "1"
      @_name = @_id.humanize
      @_full_description = ""
      @_short_description = ""
      @_path = ""
      @_formats = []

      block.arity < 1 ? instance_eval(&block) : block.call(self) if block_given?
    end

    def param(param_name, validator, desc_or_options = nil, options = {}, &block)
      param_description = Apipie::ParamDescription.new(param_name, validator, desc_or_options, options, &block)
      @_params_ordered << param_description
    end

    def error(*args)
      error_description = Apipie::ErrorDescription.new(args)
      @_errors_ordered << error_description
    end


    def path(path); @_path = path; end

    def version(version); @_version = version; end

    def formats(formats); @_formats = formats; end

    def name(name); @_name = name; end

    def short(short); @_short_description = short; end
    alias :short_description :short

    def desc(description)
      description ||= ''
      @_full_description = Apipie.markup_to_html(description)
    end
    alias :description :desc
    alias :full_description :desc

    # add description of resource method
    def add_method(mapi_key)
      @_methods << mapi_key
      @_methods.uniq!
    end

    def doc_url
      Apipie.full_url(@_id)
    end

    def api_url; "#{Apipie.configuration.api_base_url}#{@_path}"; end

    def to_json(method_name = nil)

      _methods = if method_name.blank?
        @_methods.collect { |key| Apipie.method_descriptions[key].to_json }
      else
        [Apipie.method_descriptions[[@_id, method_name].join('#')].to_json]
      end

      {
        :doc_url => doc_url,
        :api_url => api_url,
        :name => @_name,
        :short_description => @_short_description,
        :full_description => @_full_description,
        :version => @_version,
        :formats => @_formats,
        :methods => _methods
      }
    end
  end
end
