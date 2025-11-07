# frozen_string_literal: true

module RubocopChallenger
  module Bundler
    # To execute bundler command
    class Command
      include PrComet::CommandLine

      def initialize(verbose: false)
        @verbose = verbose
      end

      # Executes `$ bundle update` which excludes not installed gems
      #
      # @param gem_names [Array<String>] The target gem names
      def update(*gem_names)
        target_gems = gem_names.select { |gem_name| installed?(gem_name) }
        return if target_gems.empty?

        run('update', *target_gems, '--conservative')
      end

      # Checks the gem is installed
      #
      # @return [Boolean] Returns true if installed
      def installed?(gem_name)
        !run('list', '|', 'grep', "' #{gem_name} '").empty?
      end

      private

      def run(*subcommands)
        command = "bundle #{subcommands.join(' ')}"
        execute(command)
      end
    end
  end
end
