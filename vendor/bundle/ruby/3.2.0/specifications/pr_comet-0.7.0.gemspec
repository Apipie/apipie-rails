# -*- encoding: utf-8 -*-
# stub: pr_comet 0.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "pr_comet".freeze
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["ryz310".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-07-14"
  s.description = "It helps to create a pull request on your script".freeze
  s.email = ["ryz310@gmail.com".freeze]
  s.homepage = "https://github.com/ryz310/pr_comet".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Create a lots of pull request like comets".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<octokit>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rainbow>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.2"])
  s.add_development_dependency(%q<pry-byebug>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec_junit_formatter>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-performance>.freeze, [">= 0"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["= 0.21.2"])
  s.add_development_dependency(%q<yard>.freeze, [">= 0"])
end
