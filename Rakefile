require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

desc 'Check code styling.'
RuboCop::RakeTask.new

desc 'Run specs.'
RSpec::Core::RakeTask.new(:spec)

desc 'Check code styling and run specs'
task :build do
  Rake::Task['rubocop'].invoke
  Rake::Task['spec'].invoke
end

desc 'Default: Check code styling and run specs.'
task default: :build

desc 'Generate code coverage'
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end
