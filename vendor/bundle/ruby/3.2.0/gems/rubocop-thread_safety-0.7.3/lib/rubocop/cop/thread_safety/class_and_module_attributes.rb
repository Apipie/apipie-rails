# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid mutating class and module attributes.
      #
      # They are implemented by class variables, which are not thread-safe.
      #
      # @example
      #   # bad
      #   class User
      #     cattr_accessor :current_user
      #   end
      class ClassAndModuleAttributes < Base
        MSG = 'Avoid mutating class and module attributes.'
        RESTRICT_ON_SEND = %i[
          mattr_writer mattr_accessor cattr_writer cattr_accessor
          class_attribute
          attr attr_accessor attr_writer
          attr_internal attr_internal_accessor attr_internal_writer
        ].freeze

        # @!method mattr?(node)
        def_node_matcher :mattr?, <<~MATCHER
          (send nil?
            {:mattr_writer :mattr_accessor :cattr_writer :cattr_accessor}
            ...)
        MATCHER

        # @!method attr?(node)
        def_node_matcher :attr?, <<~MATCHER
          (send nil?
            {:attr :attr_accessor :attr_writer}
            ...)
        MATCHER

        # @!method attr_internal?(node)
        def_node_matcher :attr_internal?, <<~MATCHER
          (send nil?
            {:attr_internal :attr_internal_accessor :attr_internal_writer}
            ...)
        MATCHER

        # @!method class_attr?(node)
        def_node_matcher :class_attr?, <<~MATCHER
          (send nil?
            :class_attribute
            ...)
        MATCHER

        def on_send(node) # rubocop:disable InternalAffairs/OnSendWithoutOnCSend
          return unless mattr?(node) || (!class_attribute_allowed? && class_attr?(node)) || singleton_attr?(node)

          add_offense(node)
        end

        private

        def singleton_attr?(node)
          (attr?(node) || attr_internal?(node)) &&
            defined_in_singleton_class?(node)
        end

        def defined_in_singleton_class?(node)
          node.ancestors.each do |ancestor|
            case ancestor.type
            when :def then return false
            when :sclass then return true
            else next
            end
          end

          false
        end

        def class_attribute_allowed?
          cop_config['ActiveSupportClassAttributeAllowed']
        end
      end
    end
  end
end
