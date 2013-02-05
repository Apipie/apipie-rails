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
      :_path, :_name, :_params_ordered, :_errors_ordered, :_formats, :_parent

    def initialize(controller, resource_name, dsl_data = nil, version = nil, &block)

      @_methods = ActiveSupport::OrderedHash.new
      @_params_ordered = []
      @_errors_ordered = []

      @controller = controller
      @_id = resource_name
      @_version = version || Apipie.configuration.default_version
      @_name = @_id.humanize
      @_parent = Apipie.get_resource_description(controller.superclass, version)

      update_from_dsl_data(dsl_data) if dsl_data
    end

    def update_from_dsl_data(dsl_data)
      @_name = dsl_data[:resource_name] if dsl_data[:resource_name]
      @_full_description = Apipie.markup_to_html(dsl_data[:description])
      @_short_description = dsl_data[:short_description]
      @_path = dsl_data[:path] || ""
      @_formats = dsl_data[:formats]
      @_errors_ordered = dsl_data[:errors]
      @_params_ordered = dsl_data[:params]
      if dsl_data[:app_info]
        Apipie.configuration.app_info[_version] = dsl_data[:app_info]
      end
      if dsl_data[:api_base_url]
        Apipie.configuration.api_base_url[_version] = dsl_data[:api_base_url]
      end
    end

    def _version
      @_version || @_parent.try(:_version) || Apipie.configuration.default_version
    end

    def add_method_description(method_description)
      Apipie.debug "@resource_descriptions[#{self._version}][#{self._name}]._methods[#{method_description.method}] = #{method_description}"
      @_methods[method_description.method.to_sym] = method_description
    end

    def method_description(method_name)
      @_methods[method_name.to_sym]
    end

    def remove_method_description(method_name)
      if @_methods.has_key?(method_name)
        @_methods.delete(method_name)
      end
    end

    def method_descriptions
      @_methods.values
    end

    def doc_url
      crumbs = []
      crumbs << _version if Apipie.configuration.version_in_url
      crumbs << @_id
      Apipie.full_url crumbs.join('/')
    end

    def api_url; "#{Apipie.api_base_url(_version)}#{@_path}"; end

    def to_json(method_name = nil)

      methods = if method_name.blank?
        @_methods.collect { |key, method_description| method_description.to_json}
      else
        [@_methods[method_name.to_sym].to_json]
      end

      {
        :doc_url => doc_url,
        :api_url => api_url,
        :name => @_name,
        :short_description => @_short_description,
        :full_description => @_full_description,
        :version => _version,
        :formats => @_formats,
        :methods => methods
      }
    end

  end
end
