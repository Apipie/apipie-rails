# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid using `Dir.chdir` due to its process-wide effect.
      # If `AllowCallWithBlock` (disabled by default) option is enabled,
      # calling `Dir.chdir` with block will be allowed.
      #
      # @example
      #   # bad
      #   Dir.chdir("/var/run")
      #
      #   # bad
      #   FileUtils.chdir("/var/run")
      #
      # @example AllowCallWithBlock: false (default)
      #   # good
      #   Dir.chdir("/var/run") do
      #     puts Dir.pwd
      #   end
      #
      # @example AllowCallWithBlock: true
      #   # bad
      #   Dir.chdir("/var/run") do
      #     puts Dir.pwd
      #   end
      #
      class DirChdir < Base
        MESSAGE = 'Avoid using `%<module>s%<dot>s%<method>s` due to its process-wide effect.'
        RESTRICT_ON_SEND = %i[chdir cd].freeze

        # @!method chdir?(node)
        def_node_matcher :chdir?, <<~MATCHER
          {
            (call (const {nil? cbase} {:Dir :FileUtils}) :chdir ...)
            (call (const {nil? cbase} :FileUtils) :cd ...)
          }
        MATCHER

        def on_send(node)
          return unless chdir?(node)
          return if allow_call_with_block? && (node.block_argument? || node.parent&.block_type?)

          add_offense(
            node,
            message: format(
              MESSAGE,
              module: node.receiver.short_name,
              method: node.method_name,
              dot: node.loc.dot.source
            )
          )
        end
        alias on_csend on_send

        private

        def allow_call_with_block?
          !!cop_config['AllowCallWithBlock']
        end
      end
    end
  end
end
