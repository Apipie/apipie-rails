source "https://rubygems.org"

gemspec

# mime-types 3.0 dropped support for Ruby 1.9
group :development do
  if RUBY_VERSION.start_with? '1.9'
    gem 'mime-types', '< 3'
  end
end

# load local gemfile
local_gemfile = File.join(File.dirname(__FILE__), 'Gemfile.local')
self.instance_eval(Bundler.read_file(local_gemfile)) if File.exist?(local_gemfile)
