# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid instance variables in rack middleware.
      #
      # Middlewares are initialized once, meaning any instance variables are shared between executor threads.
      # To avoid potential race conditions, it's recommended to design middlewares to be stateless
      # or to implement proper synchronization mechanisms.
      #
      # @example
      #   # bad
      #   class CounterMiddleware
      #     def initialize(app)
      #       @app = app
      #       @counter = 0
      #     end
      #
      #     def call(env)
      #       app.call(env)
      #     ensure
      #       @counter += 1
      #     end
      #   end
      #
      #   # good
      #   class CounterMiddleware
      #     def initialize(app)
      #       @app = app
      #       @counter = Concurrent::AtomicReference.new(0)
      #     end
      #
      #     def call(env)
      #       app.call(env)
      #     ensure
      #       @counter.update { |ref| ref + 1 }
      #     end
      #   end
      #
      #   class IdentityMiddleware
      #     def initialize(app)
      #       @app = app
      #     end
      #
      #     def call(env)
      #       app.call(env)
      #     end
      #   end
      class RackMiddlewareInstanceVariable < Base
        include AllowedIdentifiers
        include OperationWithThreadsafeResult

        MSG = 'Avoid instance variables in Rack middleware.'

        RESTRICT_ON_SEND = %i[instance_variable_get instance_variable_set].freeze

        # @!method rack_middleware_like_class?(node)
        def_node_matcher :rack_middleware_like_class?, <<~MATCHER
          (class (const nil? _) nil? (begin <(def :initialize (args (arg _)+) ...) (def :call (args (arg _)) ...) ...>))
        MATCHER

        # @!method app_variable(node)
        def_node_search :app_variable, <<~MATCHER
          (def :initialize (args (arg $_) ...) `(ivasgn $_ (lvar $_)))
        MATCHER

        def on_class(node)
          return unless rack_middleware_like_class?(node)

          constructor_method = find_constructor_method(node)
          return unless (application_variable = extract_application_variable_from_contructor_method(constructor_method))

          safe_variables = extract_safe_variables_from_constructor_method(constructor_method)

          node.each_node(:def) do |def_node|
            def_node.each_node(:ivasgn, :ivar) do |ivar_node|
              variable, = ivar_node.to_a
              if variable == application_variable || safe_variables.include?(variable) || allowed_identifier?(variable)
                next
              end

              add_offense ivar_node
            end
          end
        end

        def on_send(node)
          argument = node.first_argument

          return unless argument&.type?(:sym, :str)
          return if allowed_identifier?(argument.value)

          add_offense node
        end
        alias on_csend on_send

        private

        def find_constructor_method(class_node)
          class_node
            .each_node(:def)
            .find { |node| node.method?(:initialize) && node.arguments.size >= 1 }
        end

        def extract_application_variable_from_contructor_method(constructor_method)
          constructor_method
            .then { |node| app_variable(node) }
            .then { |variables| variables.first[1] if variables.first }
        end

        def extract_safe_variables_from_constructor_method(constructor_method)
          constructor_method
            .each_node(:ivasgn)
            .select { |ivasgn_node| operation_produces_threadsafe_object?(ivasgn_node.to_a[1]) }
            .map { _1.to_a[0] }
        end
      end
    end
  end
end
