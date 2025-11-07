# -*- encoding: utf-8 -*-
# stub: mime-types-data 3.2025.0924 ruby lib

Gem::Specification.new do |s|
  s.name = "mime-types-data".freeze
  s.version = "3.2025.0924"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/mime-types/mime-types-data/issues", "changelog_uri" => "https://github.com/mime-types/mime-types-data/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/mime-types/mime-types-data/", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/mime-types/mime-types-data/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze]
  s.date = "1980-01-02"
  s.description = "mime-types-data provides a registry for information about MIME media type definitions. It can be used with the Ruby mime-types library or other software to determine defined filename extensions for MIME types, or to use filename extensions to look up the likely MIME type definitions.".freeze
  s.email = ["halostatue@gmail.com".freeze]
  s.extra_rdoc_files = ["CHANGELOG.md".freeze, "CODE_OF_CONDUCT.md".freeze, "CONTRIBUTING.md".freeze, "CONTRIBUTORS.md".freeze, "LICENCE.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "SECURITY.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "CODE_OF_CONDUCT.md".freeze, "CONTRIBUTING.md".freeze, "CONTRIBUTORS.md".freeze, "LICENCE.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "SECURITY.md".freeze]
  s.homepage = "https://github.com/mime-types/mime-types-data/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "mime-types-data provides a registry for information about MIME media type definitions".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<hoe>.freeze, ["~> 4.0"])
  s.add_development_dependency(%q<hoe-halostatue>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<mime-types>.freeze, ["> 3.6.2", "< 5"])
  s.add_development_dependency(%q<nokogiri>.freeze, ["~> 1.6"])
  s.add_development_dependency(%q<rake>.freeze, [">= 10.0", "< 14"])
  s.add_development_dependency(%q<standard>.freeze, ["~> 1.0"])
end
