# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module ThreadSafety
    # A plugin that integrates RuboCop ThreadSafety with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      # :nocov:
      def about
        LintRoller::About.new(
          name: 'rubocop-thread_safety',
          version: Version::STRING,
          homepage: 'https://github.com/rubocop/rubocop-thread_safety',
          description: 'Thread-safety checks via static analysis.'
        )
      end
      # :nocov:

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        project_root = Pathname.new(__dir__).join('../../..')

        obsoletion = project_root.join('config', 'obsoletion.yml')
        ConfigObsoletion.files << obsoletion

        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: project_root.join('config/default.yml')
        )
      end
    end
  end
end
