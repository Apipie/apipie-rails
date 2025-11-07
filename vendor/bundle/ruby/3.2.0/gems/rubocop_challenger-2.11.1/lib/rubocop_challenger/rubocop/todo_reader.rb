# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    # To read `.rubocop_todo.yml` and parse each rules
    class TodoReader
      def initialize(rubocop_todo_file_path)
        @rubocop_todo_file_path = rubocop_todo_file_path
      end

      # Returns the version of RuboCop used to create the ".rubocop_todo.yml"
      #
      # @return [Type] the RuboCop version
      def version
        file_contents =~ /using RuboCop version (\d{1,}\.\d{1,}\.\d{1,})/
        Regexp.last_match(1)
      end

      # @return [Array<Rule>]
      #   Array of rubocop rule instances which ordered by offense count
      def all_rules
        @all_rules ||=
          file_contents
          .split(/\n{2,}/)
          .drop(1) # remove header contents
          .map { |content| Rule.new(content) }
          .reject { |rule| ignored?(rule) }
          .sort
      end

      # @return [Array<Rule>]
      def autocorrectable_rules
        all_rules.select(&:autocorrectable?)
      end

      # @return [Rule]
      def least_occurrence_rule
        autocorrectable_rules.first
      end

      # @return [Rule]
      def most_occurrence_rule
        autocorrectable_rules.last
      end

      # @return [Rule]
      def any_rule
        autocorrectable_rules.sample
      end

      private

      attr_reader :rubocop_todo_file_path

      # @return [String] the ".rubocop_todo.yml" contents
      def file_contents
        @file_contents ||= File.read(rubocop_todo_file_path)
      end

      # @param rule [Rule] the target rule
      # @return [Boolean]
      def ignored?(rule)
        ignored_rules.include?(rule.title)
      end

      # @return [Array<String>] Ignored rule titles
      def ignored_rules
        @ignored_rules ||= ConfigEditor.new.ignored_rules
      end
    end
  end
end
