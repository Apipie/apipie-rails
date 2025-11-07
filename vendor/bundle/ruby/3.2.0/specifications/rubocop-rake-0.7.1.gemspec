# -*- encoding: utf-8 -*-
# stub: rubocop-rake 0.7.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop-rake".freeze
  s.version = "0.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "allowed_push_host" => "https://rubygems.org", "changelog_uri" => "https://github.com/rubocop/rubocop-rake/blob/master/CHANGELOG.md", "default_lint_roller_plugin" => "RuboCop::Rake::Plugin", "homepage_uri" => "https://github.com/rubocop/rubocop-rake", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/rubocop/rubocop-rake" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Masataka Pocke Kuwabara".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-02-16"
  s.description = "A RuboCop plugin for Rake".freeze
  s.email = ["kuwabara@pocke.me".freeze]
  s.homepage = "https://github.com/rubocop/rubocop-rake".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "A RuboCop plugin for Rake".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<lint_roller>.freeze, ["~> 1.1"])
  s.add_runtime_dependency(%q<rubocop>.freeze, [">= 1.72.1"])
end
