# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "apipie/version"

Gem::Specification.new do |s|
  s.name        = "apipie-rails"
  s.version     = Apipie::VERSION
  s.authors     = ["Pavel Pokorny","Ivan Necas"]
  s.email       = ["pajkycz@gmail.com", "inecas@redhat.com"]
  s.homepage    = "http://github.com/Pajk/apipie-rails"
  s.summary     = %q{Rails REST API documentation tool}
  s.description = %q{Maintain your API documentation up to date!}


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec-rails"
end
