# frozen_string_literal: true

module RubocopChallenger
  module Errors
    # Raise if no autocorrectable rule in the `.rubocop_todo.yml`.
    class NoAutoCorrectableRule < StandardError
      def initialize
        super 'There is no autocorrectable rule'
      end
    end
  end
end
