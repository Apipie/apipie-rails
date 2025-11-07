# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for checking if a well-known operation
    # produces an object with thread-safe semantics.
    module OperationWithThreadsafeResult
      extend NodePattern::Macros

      # @!method operation_produces_threadsafe_object?(node)
      def_node_matcher :operation_produces_threadsafe_object?, <<~PATTERN
        {
          (send (const {nil? cbase} :Queue) :new ...)
          (send
            (const (const {nil? cbase} :ThreadSafe) {:Hash :Array})
            :new ...)
          (block
            (send
              (const (const {nil? cbase} :ThreadSafe) {:Hash :Array})
              :new ...)
            ...)
          (send (const (const {nil? cbase} :Concurrent) _) :new ...)
          (block
            (send (const (const {nil? cbase} :Concurrent) _) :new ...)
            ...)
          (send (const (const (const {nil? cbase} :Concurrent) _) _) :new ...)
          (block
            (send
              (const (const (const {nil? cbase} :Concurrent) _) _)
              :new ...)
            ...)
          (send
            (const (const (const (const {nil? cbase} :Concurrent) _) _) _)
            :new ...)
          (block
            (send
              (const (const (const (const {nil? cbase} :Concurrent) _) _) _)
              :new ...)
            ...)
        }
      PATTERN
    end
  end
end
