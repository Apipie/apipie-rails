# frozen_string_literal: true

require 'pathname'
require 'yaml'

require 'rubocop'
require 'rubocop/rspec/language'

require_relative 'rubocop/rspec_rails/plugin'
require_relative 'rubocop/rspec_rails/version'

require 'rubocop/cop/rspec/base'
require_relative 'rubocop/cop/rspec_rails_cops'
