# -*- encoding: utf-8 -*-
# stub: rails-controller-testing 1.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "rails-controller-testing".freeze
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rails Core Team".freeze]
  s.date = "2020-06-23"
  s.homepage = "https://github.com/rails/rails-controller-testing".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.2.2".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Extracting `assigns` and `assert_template` from ActionDispatch.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<actionpack>.freeze, [">= 5.0.1.rc1"])
  s.add_runtime_dependency(%q<actionview>.freeze, [">= 5.0.1.rc1"])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 5.0.1.rc1"])
  s.add_development_dependency(%q<railties>.freeze, [">= 5.0.1.rc1"])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
end
