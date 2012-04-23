# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "restapi/version"

Gem::Specification.new do |s|
  s.name        = "restapi"
  s.version     = Restapi::VERSION
  s.authors     = ["Pavel Pokorny"]
  s.email       = ["pajkycz@gmail.com"]
  s.homepage    = "http://github.com/Pajk/rails-restapi"
  s.summary     = %q{REST API documentation tool}
  s.description = %q{Maintain your API documentation up to date!}


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rcov"
  #s.add_runtime_dependency "rest-client"
end
