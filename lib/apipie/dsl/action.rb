module Apipie

  # DSL is a module that provides #api, #error, #param, #error.
  module DSL

    module Action

      def def_param_group(name, &block)
        Apipie.add_param_group(self, name, &block)
      end

      #
      #   # load paths from routes and don't provide description
      #   api
      #
      def api(method, path, desc = nil, options={}) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:api] = true
        _apipie_dsl_data[:api_args] << [method, path, desc, options]
      end

      #   # load paths from routes
      #   api! "short description",
      #
      def api!(desc = nil, options={}) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:api] = true
        _apipie_dsl_data[:api_from_routes] = { :desc => desc, :options =>options }
      end

      # Reference other similar method
      #
      #   api :PUT, '/articles/:id'
      #   see "articles#create"
      #   def update; end
      def see(*args)
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:see] << args
      end

      # Show some example of what does the described
      # method return.
      def example(example) #:doc:
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:examples] << example.strip_heredoc
      end

      # Determine if the method should be included
      # in the documentation
      def show(show)
        return unless Apipie.active_dsl?
        _apipie_dsl_data[:show] = show
      end

      # Describe whole resource
      #
      # Example:
      # api :desc => "Show user profile", :path => "/users/", :version => '1.0 - 3.4.2012'
      # param :id, Fixnum, :desc => "User ID", :required => true
      # desc <<-EOS
      #   Long description...
      # EOS
      def resource_description(options = {}, &block) #:doc:
        return unless Apipie.active_dsl?
        raise ArgumentError, "Block expected" unless block_given?

        dsl_data = Resource::Description.eval_dsl(self, &block)
        versions = dsl_data[:api_versions]
        @apipie_resource_descriptions = versions.map do |version|
          Apipie.define_resource_description(self, version, dsl_data)
        end
        Apipie.set_controller_versions(self, versions)
      end
    end

  end # module DSL
end # module Apipie
