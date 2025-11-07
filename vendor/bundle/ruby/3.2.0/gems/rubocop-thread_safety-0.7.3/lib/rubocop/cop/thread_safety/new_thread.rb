# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid starting new threads.
      #
      # Let a framework like Sidekiq handle the threads.
      #
      # @example
      #   # bad
      #   Thread.new { do_work }
      class NewThread < Base
        MSG = 'Avoid starting new threads.'
        RESTRICT_ON_SEND = %i[new fork start].freeze

        # @!method new_thread?(node)
        def_node_matcher :new_thread?, <<~MATCHER
          (call (const {nil? cbase} :Thread) {:new :fork :start} ...)
        MATCHER

        def on_send(node)
          new_thread?(node) { add_offense(node) }
        end
        alias on_csend on_send
      end
    end
  end
end
