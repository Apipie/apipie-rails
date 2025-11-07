# -*- encoding: utf-8 -*-
# stub: rubocop_challenger 2.11.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop_challenger".freeze
  s.version = "2.11.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["ryosuke_sato".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-03-07"
  s.description = "Make a clean your rubocop_todo.yml with CI".freeze
  s.email = ["ryz310@gmail.com".freeze]
  s.executables = ["rubocop_challenger".freeze]
  s.files = ["exe/rubocop_challenger".freeze]
  s.homepage = "https://github.com/ryz310/rubocop_challenger".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Make a clean your rubocop_todo.yml with CI".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<pr_comet>.freeze, [">= 0.5.1", "< 0.8.0"])
  s.add_runtime_dependency(%q<rainbow>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rubocop>.freeze, [">= 0.87"])
  s.add_runtime_dependency(%q<rubocop-performance>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rubocop-rails>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rubocop-rake>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rubocop-rspec>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<rubocop-thread_safety>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<thor>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<yard>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 2.0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<simplecov>.freeze, ["= 0.22.0"])
end
