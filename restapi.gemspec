# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "restapi/version"

Gem::Specification.new do |s|
  s.name        = "restapi"
  s.version     = Restapi::VERSION
  s.authors     = ["Pavel Pokorny"]
  s.email       = ["pajkycz@gmail.com"]
  s.homepage    = "http://github.com/Pajk/restapi"
  s.summary     = %q{REST API documentation tool}
  s.description = %q{gem description}

  s.rubyforge_project = "restapi"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rcov"
  # s.add_runtime_dependency "rest-client"
end
