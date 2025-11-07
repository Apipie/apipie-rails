# Apparently this file gets loaded by Rails. Only want to define the pureruby
# task in the context of RedCloth compilation (echoe loaded).

if Gem::Specification.const_defined?(:PLATFORM_CROSS_TARGETS)
  Gem::Specification::PLATFORM_CROSS_TARGETS << "pureruby"

  task 'pureruby' do
    reset_target 'pureruby'
  end

  if target = ARGV.detect do |arg| 
    # Hack to get the platform set before the Rakefile evaluates
      Gem::Specification::PLATFORM_CROSS_TARGETS.include? arg
    end
    reset_target target
  end
end