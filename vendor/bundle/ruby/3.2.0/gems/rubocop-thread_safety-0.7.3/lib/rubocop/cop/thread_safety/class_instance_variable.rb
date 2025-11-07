# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid class instance variables.
      #
      # @example
      #   # bad
      #   class User
      #     def self.notify(info)
      #       @info = validate(info)
      #       Notifier.new(@info).deliver
      #     end
      #   end
      #
      #   class Model
      #     class << self
      #       def table_name(name)
      #         @table_name = name
      #       end
      #     end
      #   end
      #
      #   class Host
      #     %i[uri port].each do |key|
      #       define_singleton_method("#{key}=") do |value|
      #         instance_variable_set("@#{key}", value)
      #       end
      #     end
      #   end
      #
      #   module Example
      #     module ClassMethods
      #       def test(params)
      #         @params = params
      #       end
      #     end
      #   end
      #
      #   module Example
      #     class_methods do
      #       def test(params)
      #         @params = params
      #       end
      #     end
      #   end
      #
      #   module Example
      #     module_function
      #
      #     def test(params)
      #       @params = params
      #     end
      #   end
      #
      #   module Example
      #     def test(params)
      #       @params = params
      #     end
      #
      #     module_function :test
      #   end
      class ClassInstanceVariable < Base
        MSG = 'Avoid class instance variables.'
        RESTRICT_ON_SEND = %i[
          instance_variable_set
          instance_variable_get
        ].freeze

        # @!method instance_variable_set_call?(node)
        def_node_matcher :instance_variable_set_call?, <<~MATCHER
          (send nil? :instance_variable_set (...) (...))
        MATCHER

        # @!method instance_variable_get_call?(node)
        def_node_matcher :instance_variable_get_call?, <<~MATCHER
          (send nil? :instance_variable_get (...))
        MATCHER

        def on_ivar(node)
          return unless class_method_definition?(node)
          return if method_definition?(node)
          return if synchronized?(node)

          add_offense(node.loc.name)
        end
        alias on_ivasgn on_ivar

        def on_send(node) # rubocop:disable InternalAffairs/OnSendWithoutOnCSend
          return unless instance_variable_call?(node)
          return unless class_method_definition?(node)
          return if method_definition?(node)
          return if synchronized?(node)

          add_offense(node)
        end

        private

        def class_method_definition?(node)
          in_defs?(node) ||
            in_def_sclass?(node) ||
            in_def_class_methods?(node) ||
            in_def_module_function?(node) ||
            in_class_eval?(node) ||
            singleton_method_definition?(node)
        end

        def in_defs?(node)
          node.ancestors.any? do |ancestor|
            break false if new_lexical_scope?(ancestor)

            ancestor.defs_type?
          end
        end

        def in_def_sclass?(node)
          defn = node.ancestors.find do |ancestor|
            break if new_lexical_scope?(ancestor)

            ancestor.def_type?
          end

          defn&.ancestors&.any?(&:sclass_type?)
        end

        def in_def_class_methods?(node)
          in_def_class_methods_dsl?(node) || in_def_class_methods_module?(node)
        end

        def in_def_class_methods_dsl?(node)
          node.ancestors.any? do |ancestor|
            break if new_lexical_scope?(ancestor)
            next unless ancestor.block_type?

            ancestor.children.first.command? :class_methods
          end
        end

        def in_def_class_methods_module?(node)
          defn = node.ancestors.find do |ancestor|
            break if new_lexical_scope?(ancestor)

            ancestor.def_type?
          end
          return false unless defn

          mod = defn.ancestors.find do |ancestor|
            %i[class module].include?(ancestor.type)
          end
          return false unless mod

          class_methods_module?(mod)
        end

        def in_def_module_function?(node)
          defn = node.ancestors.find(&:def_type?)
          return false unless defn

          defn.left_siblings.any? { |sibling| module_function_bare_access_modifier?(sibling) } ||
            defn.right_siblings.any? { |sibling| module_function_for?(sibling, defn.method_name) }
        end

        def in_class_eval?(node)
          defn = node.ancestors.find do |ancestor|
            break if ancestor.def_type? || new_lexical_scope?(ancestor)

            ancestor.block_type?
          end
          return false unless defn

          class_eval_scope?(defn)
        end

        def singleton_method_definition?(node)
          node.ancestors.any? do |ancestor|
            break if new_lexical_scope?(ancestor)
            next unless ancestor.children.first.is_a? AST::SendNode

            ancestor.children.first.command? :define_singleton_method
          end
        end

        def method_definition?(node)
          node.ancestors.any? do |ancestor|
            break if new_lexical_scope?(ancestor)
            next unless ancestor.children.first.is_a? AST::SendNode

            ancestor.children.first.command? :define_method
          end
        end

        def synchronized?(node)
          node.ancestors.find do |ancestor|
            next unless ancestor.block_type?

            s = ancestor.children.first
            s.send_type? && s.children.last == :synchronize
          end
        end

        def instance_variable_call?(node)
          instance_variable_set_call?(node) || instance_variable_get_call?(node)
        end

        def module_function_bare_access_modifier?(node)
          return false unless node.respond_to?(:send_type?)

          node.send_type? && node.bare_access_modifier? && node.method?(:module_function)
        end

        def match_name?(arg_name, method_name)
          arg_name.to_sym == method_name.to_sym
        end

        # @!method class_methods_module?(node)
        def_node_matcher :class_methods_module?, <<~PATTERN
          (module (const _ :ClassMethods) ...)
        PATTERN

        # @!method module_function_for?(node)
        def_node_matcher :module_function_for?, <<~PATTERN
          (send nil? {:module_function} ({sym str} #match_name?(%1)))
        PATTERN

        # @!method new_lexical_scope?(node)
        def_node_matcher :new_lexical_scope?, <<~PATTERN
          {
            (block (send (const nil? :Struct) :new ...) _ (any_def ...))
            (block (send (const nil? :Class) :new ...) _ (any_def ...))
            (block (send (const nil? :Data) :define ...) _ (any_def ...))
            (block
              (send nil?
                {
                  :prepend_around_action
                  :prepend_before_action
                  :before_action
                  :append_before_action
                  :around_action
                  :append_around_action
                  :append_after_action
                  :after_action
                  :prepend_after_action
                }
              )
              ...
            )
          }
        PATTERN

        # @!method class_eval_scope?(node)
        def_node_matcher :class_eval_scope?, <<~PATTERN
          (block (send (const {nil? cbase} _) {:class_eval :class_exec}) ...)
        PATTERN
      end
    end
  end
end
