# -*- encoding: utf-8 -*-
# stub: mime-types 3.7.0 ruby lib

Gem::Specification.new do |s|
  s.name = "mime-types".freeze
  s.version = "3.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/mime-types/ruby-mime-types/issues", "changelog_uri" => "https://github.com/mime-types/ruby-mime-types/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/mime-types/ruby-mime-types/", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/mime-types/ruby-mime-types/" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Austin Ziegler".freeze]
  s.date = "2025-05-07"
  s.description = "The mime-types library provides a library and registry for information about\nMIME content type definitions. It can be used to determine defined filename\nextensions for MIME types, or to use filename extensions to look up the likely\nMIME type definitions.\n\nVersion 3.0 is a major release that requires Ruby 2.0 compatibility and removes\ndeprecated functions. The columnar registry format introduced in 2.6 has been\nmade the primary format; the registry data has been extracted from this library\nand put into [mime-types-data][data]. Additionally, mime-types is now licensed\nexclusively under the MIT licence and there is a code of conduct in effect.\nThere are a number of other smaller changes described in the History file.".freeze
  s.email = ["halostatue@gmail.com".freeze]
  s.extra_rdoc_files = ["CHANGELOG.md".freeze, "CODE_OF_CONDUCT.md".freeze, "CONTRIBUTING.md".freeze, "CONTRIBUTORS.md".freeze, "LICENCE.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "SECURITY.md".freeze]
  s.files = ["CHANGELOG.md".freeze, "CODE_OF_CONDUCT.md".freeze, "CONTRIBUTING.md".freeze, "CONTRIBUTORS.md".freeze, "LICENCE.md".freeze, "Manifest.txt".freeze, "README.md".freeze, "SECURITY.md".freeze]
  s.homepage = "https://github.com/mime-types/ruby-mime-types/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "The mime-types library provides a library and registry for information about MIME content type definitions".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<mime-types-data>.freeze, ["~> 3.2025", ">= 3.2025.0507"])
  s.add_runtime_dependency(%q<logger>.freeze, [">= 0"])
  s.add_development_dependency(%q<hoe>.freeze, ["~> 4.0"])
  s.add_development_dependency(%q<hoe-halostatue>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<hoe-rubygems>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
  s.add_development_dependency(%q<minitest-autotest>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<minitest-focus>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<minitest-hooks>.freeze, ["~> 1.4"])
  s.add_development_dependency(%q<rake>.freeze, [">= 10.0", "< 14"])
  s.add_development_dependency(%q<rdoc>.freeze, [">= 0.0"])
  s.add_development_dependency(%q<standard>.freeze, ["~> 1.0"])
end
