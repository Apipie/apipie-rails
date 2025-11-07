# -*- encoding: utf-8 -*-
redcloth_dir = Dir.pwd =~ /redcloth\/tmp/ ? File.expand_path("../../../..", Dir.pwd) : File.expand_path("..", __FILE__)
$LOAD_PATH.unshift File.join(redcloth_dir, 'lib')
require "redcloth/version"

Gem::Specification.new do |s|
  s.name        = "RedCloth"
  s.version     = RedCloth::VERSION.to_s
  s.authors     = ["Jason Garber", "Joshua Siler", "Ola Bini"]
  s.description = "Textile parser for Ruby."
  s.summary     = RedCloth::SUMMARY
  s.homepage    = "https://github.com/jgarber/redcloth"
  s.license = "MIT"

  s.platform = 'ruby'
  s.required_ruby_version = Gem::Requirement.new(">= 2.4")
  s.rubygems_version   = "1.3.7"

  if s.respond_to?(:metadata=)
    s.metadata = {
      "bug_tracker_uri" => "https://github.com/jgarber/redcloth/issues",
      "changelog_uri" => "https://github.com/jgarber/redcloth/blob/master/CHANGELOG",
      "source_code_uri" => "https://github.com/jgarber/redcloth"
    }
  end

  s.files            = Dir['.gemtest', '.rspec', 'CHANGELOG', 'COPYING', 'Gemfile', 'README.rdoc', 'Rakefile', 'doc/**/*', 'bin/**/*', 'lib/**/*', 'redcloth.gemspec', 'spec/**/*', 'tasks/**/*']
  s.test_files       = Dir['spec/**/*']
  s.executables      = ['redcloth']
  s.extra_rdoc_files = ["README.rdoc", "COPYING", "CHANGELOG"]
  s.rdoc_options     = ["--charset=UTF-8", "--line-numbers", "--inline-source", "--title", "RedCloth", "--main", "README.rdoc"]
  s.require_paths   += ["lib/case_sensitive_require", "ext"]

  s.files -= Dir['lib/**/*.bundle']
  s.files -= Dir['lib/**/*.so']

  s.files += %w[attributes inline scan].map {|f| "ext/redcloth_scan/redcloth_#{f}.c"}
  s.files += ["ext/redcloth_scan/redcloth.h"]
  s.extensions = Dir['ext/**/extconf.rb']

  s.add_development_dependency('bundler', '> 1.3.4')
  s.add_development_dependency('rake', '~> 13')
  s.add_development_dependency('rspec', '~> 3.12')
  s.add_development_dependency('diff-lcs', '~> 1.5')

end