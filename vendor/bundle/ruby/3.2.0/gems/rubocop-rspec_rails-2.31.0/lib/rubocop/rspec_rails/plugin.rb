# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module RSpecRails
    # A plugin that integrates RuboCop RSpecRails with RuboCop's plugin system.
    class Plugin < LintRoller::Plugin
      # :nocov:
      def about
        LintRoller::About.new(
          name: 'rubocop-rspec_rails',
          version: Version::STRING,
          homepage: 'https://github.com/rubocop/rubocop-rspec_rails',
          description: 'Code style checking for RSpec Rails files.'
        )
      end
      # :nocov:

      def supported?(context)
        context.engine == :rubocop
      end

      def rules(_context)
        project_root = Pathname.new(__dir__).join('../../..')

        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: project_root.join('config/default.yml')
        )
      end
    end
  end
end
