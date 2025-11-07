require 'rvm'

namespace :rvm do
  
  RVM_RUBIES = ['ruby-1.8.6-p398', 'ruby-1.9.1-p243', 'ruby-1.9.2-p136', 'ruby-2.2.3p173']
  RVM_GEMSET_NAME = 'redcloth'
  
  task :setup do
    unless @rvm_setup
      rvm_lib_path = "#{`echo $rvm_path`.strip}/lib"
      #$LOAD_PATH.unshift(rvm_lib_path) unless $LOAD_PATH.include?(rvm_lib_path)
      require 'rvm'
      require 'tmpdir'
      @rvm_setup = true
    end
  end
  
  desc "Runs specs under each rvm ruby"
  task :spec => :setup do
    puts rvm_rubies.join(',')
    rvm_each_rubie do
      # Make sure all dependencies are installed but ignore Gemfile.lock. It 
      # gets confused when locked to java and running ruby and vice-versa.
      STDERR << RVM.run('bundle update').stderr 
            
      result = RVM.run("rake test")
      STDOUT << result.stdout
      STDERR << result.stderr
    end
  end
  
  desc "Show rubies"
  task :rubies => :setup do
    puts rvm_rubies.join(",")
  end
  
  namespace :install do
    task :rubies => :setup do
      installed_rubies = RVM.list_strings
      RVM_RUBIES.each do |rubie|
        if installed_rubies.include?(rubie)
          puts "info: Rubie #{rubie} already installed."
        else
          good_msg = "info: Rubie #{rubie} installed."
          bad_msg = "Failed #{rubie} install! Check RVM logs here: #{RVM.path}/log/#{rubie}"
          puts "info: Rubie #{rubie} installation inprogress. This could take awhile..."
          if RVM.install(rubie,{})
            puts(good_msg)
            RVM.use(rubie)
            RVM.perform_set_operation(:gem, 'install', 'bundler')
            RVM.reset_current!
          else
            abort(bad_msg)
          end
        end
      end
    end
  end

  task :remove => :setup do
    rvm_rubies.each { |rubie| RVM.remove(rubie) }
  end
end


# RVM Helper Methods

def rvm_each_rubie
  rvm_rubies.each do |rubie|
    RVM.use(rubie)
    puts "Using #{rubie}"
    yield
  end
ensure
  RVM.reset_current!
end

def rvm_rubies(options={})
  RVM_RUBIES.map{ |rubie| "#{rubie}@#{RVM_GEMSET_NAME}" }
end

