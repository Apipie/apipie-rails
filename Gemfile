# frozen_string_literal: true

source 'https://rubygems.org'

gemspec path: '.'

# use ENV vars, with default value as fallback for local setup
gem 'actionpack', "~> #{ENV['RAILS_VERSION'] || '7.1'}.0"
gem 'activesupport', "~> #{ENV['RAILS_VERSION'] || '7.1'}.0"

gem 'mime-types' # , '~> 3.0'
gem 'rails-controller-testing'
gem 'rspec-rails' # , '~> 5.0'

# net-smtp not included by default in Ruby 3.1
# Will be fixed by https://github.com/mikel/mail/pull/1439
gem 'net-smtp', require: false if Gem.ruby_version >= Gem::Version.new('3.1.0')

gem 'test_engine', path: './spec/dummy/components/test_engine', group: :test
