# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    # To edit `.rubocop_todo.yml`
    class TodoWriter
      def initialize(source, destination = source)
        @source = source
        @destination = destination
      end

      def delete_rule(rubocop_rule)
        current_data = File.read(source)
        contents = current_data.sub("\n#{rubocop_rule.contents}", '')
        File.write(destination, contents)
      end

      private

      attr_reader :source, :destination
    end
  end
end
