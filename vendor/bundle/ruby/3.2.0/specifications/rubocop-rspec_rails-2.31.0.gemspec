# -*- encoding: utf-8 -*-
# stub: rubocop-rspec_rails 2.31.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop-rspec_rails".freeze
  s.version = "2.31.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/rubocop/rubocop-rspec_rails/blob/master/CHANGELOG.md", "default_lint_roller_plugin" => "RuboCop::RSpecRails::Plugin", "documentation_uri" => "https://docs.rubocop.org/rubocop-rspec_rails/", "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Benjamin Quorning".freeze, "Phil Pirozhkov".freeze, "Maxim Krizhanovsky".freeze, "Yudai Takada".freeze]
  s.date = "2025-03-10"
  s.description = "Code style checking for RSpec Rails files.\nA plugin for the RuboCop code style enforcing & linting tool.\n".freeze
  s.extra_rdoc_files = ["MIT-LICENSE.md".freeze, "README.md".freeze]
  s.files = ["MIT-LICENSE.md".freeze, "README.md".freeze]
  s.homepage = "https://github.com/rubocop/rubocop-rspec_rails".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Code style checking for RSpec Rails files".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<lint_roller>.freeze, ["~> 1.1"])
  s.add_runtime_dependency(%q<rubocop>.freeze, ["~> 1.72", ">= 1.72.1"])
  s.add_runtime_dependency(%q<rubocop-rspec>.freeze, ["~> 3.5"])
end
