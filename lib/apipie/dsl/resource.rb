# Apipie DSL functions.
module Apipie

  # DSL is a module that provides #api, #error, #param, #error.
  module DSL

    module Resource

      class Description
        include Apipie::DSL::Base
        include Apipie::DSL::Common
        include Apipie::DSL::Resource
        include Apipie::DSL::Param

        def initialize(controller)
          @controller = controller
        end

        def _eval_dsl(&block)
          instance_eval(&block)
          return _apipie_dsl_data
        end

        # evaluates resource description DSL and returns results
        def self.eval_dsl(controller, &block)
          dsl_data  = self.new(controller)._eval_dsl(&block)
          if dsl_data[:api_versions].empty?
            dsl_data[:api_versions] = Apipie.controller_versions(controller)
          end
          dsl_data
        end
      end

      # by default, the resource id is derived from controller_name
      # it can be overwritten with.
      #
      #    resource_id "my_own_resource_id"
      def resource_id(resource_id)
        Apipie.set_resource_id(@controller, resource_id)
      end

      def name(name)
        _apipie_dsl_data[:resource_name] = name
      end

      def api_base_url(url)
        _apipie_dsl_data[:api_base_url] = url
      end

      def short(short)
        _apipie_dsl_data[:short_description] = short
      end
      alias :short_description :short

      def path(path)
        _apipie_dsl_data[:path] = path
      end

      def app_info(app_info)
        _apipie_dsl_data[:app_info] = app_info
      end
    end

  end # module DSL
end # module Apipie
