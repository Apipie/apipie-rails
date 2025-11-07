module Rake
  module RagelGenerationTasks
    RAGEL_INCLUDE_PATTERN = /include \w+ "([^"]+)";/
    RAGEL_VERSION_COMMAND = "ragel -v"
    
    attr_accessor :rl_dir
    attr_accessor :machines
    
    def init(name = nil, gem_spec = nil)
      super
      
      @rl_dir = "ragel"
      @machines = %w(scan inline attributes)
    end
    
    def lang
      raise NotImplementedError
    end
    
    def source_files
      @source_files ||= machines.map {|m| target(m) }
    end
    
    def define
      super
      define_ragel_tasks
    end
    
    def define_ragel_tasks
      machines.each do |machine|
        file target(machine) => [*ragel_sources(machine)] do
          mkdir_p(File.dirname(target(machine))) unless File.directory?(File.dirname(target(machine)))
          ensure_ragel_version
          sh "ragel #{flags} #{lang_ragel(machine)} -o #{target(machine)}"
        end
        
        file extconf => [target(machine)] if lang == 'c'
      end
    end

    def target(machine)
      {
        'scan' => {
          'c'    => "#{@ext_dir}/redcloth_scan.c",
          'rb'   => "#{@ext_dir}/redcloth_scan.rb"
        },
        'inline' => {
          'c'    => "#{@ext_dir}/redcloth_inline.c",
          'rb'   => "#{@ext_dir}/redcloth_inline.rb"
        },
        'attributes' => {
          'c'    => "#{@ext_dir}/redcloth_attributes.c",
          'rb'   => "#{@ext_dir}/redcloth_attributes.rb"
        }
      }[machine][lang]
    end

    def lang_ragel(machine)
      "#{@rl_dir}/redcloth_#{machine}.#{lang}.rl"
    end

    def ragel_sources(machine)
      deps = [lang_ragel(machine), ragel_file_dependencies(lang_ragel(machine))].flatten.dup
      deps += ["#{@ext_dir}/redcloth.h"] if lang == 'c'
      deps
      # FIXME: merge that header file into other places so it can be eliminated?
    end
    
    def ragel_file_dependencies(ragel_file)
      found = find_ragel_includes(ragel_file)
      found + found.collect {|file| ragel_file_dependencies(file)}
    end
    
    def find_ragel_includes(file)
      File.open(file).grep(RAGEL_INCLUDE_PATTERN) { $1 }.map do |file|
        "#{@rl_dir}/#{file}"
      end
    end

    def flags
      code_style_flag = preferred_code_style ? " -" + preferred_code_style : ""
      "-#{host_language_flag}#{code_style_flag}"
    end

    def host_language_flag
      {
        'c'      => 'C',
        'rb'     => 'R'
      }[lang]
    end

    def preferred_code_style
      {
        'c'      => 'T0',
        'rb'     => 'F1'
      }[lang]
    end

    def ensure_ragel_version
      @ragel_v ||= `ragel -v`[/(version )(\S*)/,2].split('.').map{|s| s.to_i}
      raise unless @ragel_v[0] > 6 || (@ragel_v[0] == 6 && @ragel_v[1] >= 3)
    rescue
      STDERR.puts "Ragel 6.3 or greater is required."
      exit(1)
    end
    
  end
  class RagelExtensionTask < ExtensionTask
    include RagelGenerationTasks

    def lang
      "c"
    end
  end  
  
end