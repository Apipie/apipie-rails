# frozen_string_literal: true

class PrComet
  # Test helper module for RSpec
  module Stub
    def stub_pr_comet!
      instance_double(PrComet, create!: true).tap do |pr_comet|
        allow(pr_comet).to receive(:commit) { |_message, &block| block&.call }
        allow(PrComet).to receive(:new).and_return(pr_comet)
      end
    end
  end
end
