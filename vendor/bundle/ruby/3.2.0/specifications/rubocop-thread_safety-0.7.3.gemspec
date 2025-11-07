# -*- encoding: utf-8 -*-
# stub: rubocop-thread_safety 0.7.3 ruby lib

Gem::Specification.new do |s|
  s.name = "rubocop-thread_safety".freeze
  s.version = "0.7.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/rubocop/rubocop-thread_safety/issues", "changelog_uri" => "https://github.com/rubocop/rubocop-thread_safety/blob/master/CHANGELOG.md", "default_lint_roller_plugin" => "RuboCop::ThreadSafety::Plugin", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/rubocop/rubocop-thread_safety" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Michael Gee".freeze]
  s.bindir = "exe".freeze
  s.date = "1980-01-02"
  s.description = "    Thread-safety checks via static analysis.\n    A plugin for the RuboCop code style enforcing & linting tool.\n".freeze
  s.email = ["michaelpgee@gmail.com".freeze]
  s.homepage = "https://github.com/rubocop/rubocop-thread_safety".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Thread-safety checks via static analysis".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<lint_roller>.freeze, ["~> 1.1"])
  s.add_runtime_dependency(%q<rubocop>.freeze, ["~> 1.72", ">= 1.72.1"])
  s.add_runtime_dependency(%q<rubocop-ast>.freeze, [">= 1.44.0", "< 2.0"])
end
