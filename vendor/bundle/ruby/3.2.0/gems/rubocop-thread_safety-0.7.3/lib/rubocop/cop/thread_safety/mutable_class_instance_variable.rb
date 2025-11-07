# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Checks whether some class instance variable isn't a
      # mutable literal (e.g. array or hash).
      #
      # It is based on Style/MutableConstant from RuboCop.
      # See https://github.com/rubocop/rubocop/blob/master/lib/rubocop/cop/style/mutable_constant.rb
      #
      # Class instance variables are a risk to threaded code as they are shared
      # between threads. A mutable object such as an array or hash may be
      # updated via an attr_reader so would not be detected by the
      # ThreadSafety/ClassAndModuleAttributes cop.
      #
      # Strict mode can be used to freeze all class instance variables, rather
      # than just literals.
      # Strict mode is considered an experimental feature. It has not been
      # updated with an exhaustive list of all methods that will produce frozen
      # objects so there is a decent chance of getting some false positives.
      # Luckily, there is no harm in freezing an already frozen object.
      #
      # @example EnforcedStyle: literals (default)
      #   # bad
      #   class Model
      #     @list = [1, 2, 3]
      #   end
      #
      #   # good
      #   class Model
      #     @list = [1, 2, 3].freeze
      #   end
      #
      #   # good
      #   class Model
      #     @var = <<~TESTING.freeze
      #       This is a heredoc
      #     TESTING
      #   end
      #
      #   # good
      #   class Model
      #     @var = Something.new
      #   end
      #
      # @example EnforcedStyle: strict
      #   # bad
      #   class Model
      #     @var = Something.new
      #   end
      #
      #   # bad
      #   class Model
      #     @var = Struct.new do
      #       def foo
      #         puts 1
      #       end
      #     end
      #   end
      #
      #   # good
      #   class Model
      #     @var = Something.new.freeze
      #   end
      #
      #   # good
      #   class Model
      #     @var = Struct.new do
      #       def foo
      #         puts 1
      #       end
      #     end.freeze
      #   end
      class MutableClassInstanceVariable < Base
        extend AutoCorrector

        include FrozenStringLiteral
        include ConfigurableEnforcedStyle
        include OperationWithThreadsafeResult

        MSG = 'Freeze mutable objects assigned to class instance variables.'
        FROZEN_STRING_LITERAL_TYPES_RUBY27 = %i[str dstr].freeze
        FROZEN_STRING_LITERAL_TYPES_RUBY30 = %i[str].freeze

        def on_ivasgn(node)
          return unless in_class?(node)

          on_assignment(node.expression)
        end

        def on_or_asgn(node)
          return unless node.assignment_node.ivasgn_type?
          return unless in_class?(node)

          on_assignment(node.expression)
        end

        def on_masgn(node)
          return unless in_class?(node)

          mlhs, values = *node # rubocop:disable InternalAffairs/NodeDestructuring
          return unless values.array_type?

          mlhs.to_a.zip(values.to_a).each do |lhs, value|
            next unless lhs.ivasgn_type?

            on_assignment(value)
          end
        end

        def autocorrect(corrector, node)
          expr = node.source_range

          splat_value = splat_value(node)
          if splat_value
            correct_splat_expansion(corrector, expr, splat_value)
          elsif node.array_type? && !node.bracketed?
            corrector.insert_before(expr, '[')
            corrector.insert_after(expr, ']')
          elsif requires_parentheses?(node)
            corrector.insert_before(expr, '(')
            corrector.insert_after(expr, ')')
          end

          corrector.insert_after(expr, '.freeze')
        end

        private

        def frozen_string_literal?(node)
          literal_types = if target_ruby_version >= 3.0
                            FROZEN_STRING_LITERAL_TYPES_RUBY30
                          else
                            FROZEN_STRING_LITERAL_TYPES_RUBY27
                          end
          literal_types.include?(node.type) && frozen_string_literals_enabled?
        end

        def on_assignment(value)
          if style == :strict
            strict_check(value)
          else
            check(value)
          end
        end

        def strict_check(value)
          return if immutable_literal?(value)
          return if operation_produces_immutable_object?(value)
          return if operation_produces_threadsafe_object?(value)
          return if frozen_string_literal?(value)

          add_offense(value) do |corrector|
            autocorrect(corrector, value)
          end
        end

        def check(value)
          return unless mutable_literal?(value) ||
                        range_enclosed_in_parentheses?(value)
          return if frozen_string_literal?(value)

          add_offense(value) do |corrector|
            autocorrect(corrector, value)
          end
        end

        def in_class?(node)
          container = node.ancestors.find do |ancestor|
            container?(ancestor)
          end
          return false if container.nil?

          %i[class module].include?(container.type)
        end

        def container?(node)
          return true if define_singleton_method?(node)
          return true if define_method?(node)

          %i[def defs class module].include?(node.type)
        end

        def mutable_literal?(node)
          return false if node.nil?

          node.mutable_literal? || range_type?(node)
        end

        def immutable_literal?(node)
          node.nil? || node.immutable_literal?
        end

        def requires_parentheses?(node)
          range_type?(node) ||
            (node.send_type? && (node.loc.dot.nil? || (node.arguments.any? && !node.parenthesized_call?)))
        end

        def range_type?(node)
          node.type?(:range)
        end

        def correct_splat_expansion(corrector, expr, splat_value)
          if range_enclosed_in_parentheses?(splat_value)
            corrector.replace(expr, "#{splat_value.source}.to_a")
          else
            corrector.replace(expr, "(#{splat_value.source}).to_a")
          end
        end

        # @!method define_singleton_method?(node)
        def_node_matcher :define_singleton_method?, <<~PATTERN
          (block (send nil? :define_singleton_method ...) ...)
        PATTERN

        # @!method define_method?(node)
        def_node_matcher :define_method?, <<~PATTERN
          (block (send nil? :define_method ...) ...)
        PATTERN

        # @!method splat_value(node)
        def_node_matcher :splat_value, <<~PATTERN
          (array (splat $_))
        PATTERN

        # NOTE: Some of these patterns may not actually return an immutable
        # object but we will consider them immutable for this cop.
        # @!method operation_produces_immutable_object?(node)
        def_node_matcher :operation_produces_immutable_object?, <<~PATTERN
          {
            (const _ _)
            (send (const {nil? cbase} :Struct) :new ...)
            (block (send (const {nil? cbase} :Struct) :new ...) ...)
            (send _ :freeze)
            (send {float int} {:+ :- :* :** :/ :% :<<} _)
            (send _ {:+ :- :* :** :/ :%} {float int})
            (send _ {:== :=== :!= :<= :>= :< :>} _)
            (send (const {nil? cbase} :ENV) :[] _)
            (or (send (const {nil? cbase} :ENV) :[] _) _)
            (send _ {:count :length :size} ...)
            (block (send _ {:count :length :size} ...) ...)
          }
        PATTERN

        # @!method range_enclosed_in_parentheses?(node)
        def_node_matcher :range_enclosed_in_parentheses?, <<~PATTERN
          (begin (range _ _))
        PATTERN
      end
    end
  end
end
