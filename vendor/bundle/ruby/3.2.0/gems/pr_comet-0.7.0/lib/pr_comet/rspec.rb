# frozen_string_literal: true

require 'pr_comet'
require 'pr_comet/rspec/stub'

RSpec.configure do |config|
  config.include PrComet::Stub
end
