# frozen_string_literal: true

class PrComet
  module Errors
    # Common error class
    class Error < StandardError; end

    # Un-commited modify was detected on the local
    class ExistUncommittedModify < Error; end
  end
end
