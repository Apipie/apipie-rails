source "https://rubygems.org"

gemspec

gem 'test_engine', path: 'spec/dummy/components/test_engine', group: :test

# load local gemfile
local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
self.instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
