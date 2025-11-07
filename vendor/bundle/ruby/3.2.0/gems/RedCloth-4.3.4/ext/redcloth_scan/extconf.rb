require 'mkmf'
CONFIG['warnflags'].gsub!(/-Wshorten-64-to-32/, '') if CONFIG['warnflags']
$CFLAGS << ' -O0 -Wall ' if CONFIG['CC'] =~ /gcc/
dir_config("redcloth_scan")
create_makefile("redcloth_scan")
