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

    def initialize(controller, resource_name, version = nil, &block)

      @_methods = ActiveSupport::OrderedHash.new
      @_params_ordered = []
      @_errors_ordered = []

      @controller = controller
      @_id = resource_name
      @_version = version || Apipie.configuration.default_version
      @_name = @_id.humanize
      @_full_description = ""
      @_short_description = ""
      @_path = ""
      @_parent = Apipie.get_resource_description(controller.superclass, version)
      @_formats = []

      eval_resource_description(&block)
    end

    def eval_resource_description(&block)
      block.arity < 1 ? instance_eval(&block) : block.call(self) if block_given?
    end

    def app_info(description)
      Apipie.configuration.app_info[_version] = description
    end

    def api_base_url(url)
      Apipie.configuration.api_base_url[_version] = url
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

    # this keyword is handled by Apipie::ResourceDescription::VersionsExtractor
    def api_version(version);; end

    def _version
      @_version || @_parent.try(:_version) || Apipie.configuration.default_version
    end

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

    # Get's versions that the resource is defined for. It can't be
    # done inside the ResourceDescription itself, becuase the resource
    # description belongs to one versions, i.e. every version has it's
    # own ResourceDescription instance.
    class VersionsExtractor
      attr_reader :_versions

      def initialize(&block)
        @_versions = []
        instance_eval(&block)
      end

      def self.versions(&block)
        self.new(&block)._versions
      end

      def api_version(api_version)
        @_versions << api_version
      end

      def method_missing(*args)
        # we ignore the rest of DSL
        true
      end
    end
  end
end
