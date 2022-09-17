# -*- encoding: utf-8 -*-
$:.push File.expand_path('lib', __dir__)
require "apipie/version"

Gem::Specification.new do |s|
  s.name        = "apipie-rails"
  s.version     = Apipie::VERSION
  s.authors     = ["Pavel Pokorny","Ivan Necas"]
  s.email       = ["pajkycz@gmail.com", "inecas@redhat.com"]
  s.homepage    = "http://github.com/Apipie/apipie-rails"
  s.summary     = %q{Rails REST API documentation tool}
  s.description = %q{Rails REST API documentation tool}
  s.required_ruby_version = '>= 2.6.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "actionpack", ">= 5.0"
  s.add_dependency "activesupport", ">= 5.0"

  # Optional dependencies
  s.add_development_dependency "maruku"   # for Markdown support
  s.add_development_dependency "RedCloth" # for Textile support

  # Dev/tests only dependencies
  s.add_development_dependency "json-schema", "~> 2.8"
  s.add_development_dependency "rspec-rails", "~> 3.0"
  s.add_development_dependency "rake"
  s.add_development_dependency 'rubocop_challenger'
  s.add_development_dependency "simplecov"
  s.add_development_dependency "sqlite3"
end
