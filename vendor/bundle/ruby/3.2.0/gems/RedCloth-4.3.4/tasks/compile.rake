CLEAN.include [
  'tmp',
  '**/*.{o,obj,class,pdb,lib,def,exp,log,rbc}',
  'ext/redcloth_scan/**/redcloth_*.rb',
  'ext/redcloth_scan/Makefile',  'ext/redcloth_scan/extconf.rb',
]
CLOBBER.include [
  'pkg',
  '**/*.{c,java}',
  'lib/**/*.{bundle,so,o,obj,pdb,lib,def,exp,jar}',
  'lib/redcloth_scan.rb',
]

# Load the Gem specification for the current platform (Ruby or JRuby).
def gemspec(platform = 'ruby')
  Gem::Specification.load(File.expand_path('../../redcloth.gemspec', __FILE__))
end

require 'rake/extensiontask'
require File.dirname(__FILE__) + '/ragel_extension_task'


extconf = "ext/redcloth_scan/extconf.rb"
file extconf do
    FileUtils.mkdir(File.dirname(extconf)) unless File.directory?(File.dirname(extconf))
    File.open(extconf, "w") do |io|
      io.write(<<-EOF)
require 'mkmf'
CONFIG['warnflags'].gsub!(/-Wshorten-64-to-32/, '') if CONFIG['warnflags']
$CFLAGS << ' -O0 -Wall ' if CONFIG['CC'] =~ /gcc/
dir_config("redcloth_scan")
create_makefile("redcloth_scan")
      EOF
    end
end

Rake::RagelExtensionTask.new("redcloth_scan", gemspec) do |ext|
end