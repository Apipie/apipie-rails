# encoding: utf-8
require 'rubygems'
require 'bundler'

require 'rake/clean'

if File.directory? "ragel"
  Bundler.setup
  Bundler::GemHelper.install_tasks
  Dir['tasks/**/*.rake'].each { |rake| load File.expand_path(rake) }
else
  # Omit generation/compile tasks and dependencies. In a gem package 
  # we only need tasks and dependencies required for running specs.
  Bundler.settings.without = [:compilation]
  Bundler.setup(:default, :development)
  load 'tasks/rspec.rake'
end
