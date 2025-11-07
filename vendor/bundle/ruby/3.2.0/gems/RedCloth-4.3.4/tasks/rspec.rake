require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |t|
  t.rcov = true
  t.rcov_opts = %w{--exclude osx\/objc,gems\/,spec\/}
end

task :default  => :spec
task :spec     => :compile

RSpec::Core::RakeTask.new(:test) # for rubygems-test