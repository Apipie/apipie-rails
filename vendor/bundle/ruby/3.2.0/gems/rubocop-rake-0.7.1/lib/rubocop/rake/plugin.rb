# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module Rake
    # A plugin that integrates RuboCop Rake with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-rake',
          version: VERSION,
          homepage: 'https://github.com/rubocop/rubocop-rake',
          description: 'A RuboCop plugin for Rake.',
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../../../config/default.yml'),
        )
      end
    end
  end
end
