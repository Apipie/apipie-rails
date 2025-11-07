require "rubygems"
require "hoe"
require "rake/clean"
require "minitest"
require "minitest/test_task"

Hoe.plugin :halostatue
Hoe.plugin :rubygems

Hoe.plugins.delete :debug
Hoe.plugins.delete :newb
Hoe.plugins.delete :publish
Hoe.plugins.delete :signing
Hoe.plugins.delete :test

spec = Hoe.spec "mime-types" do
  developer("Austin Ziegler", "halostatue@gmail.com")

  self.trusted_release = ENV["rubygems_release_gem"] == "true"

  require_ruby_version ">= 2.0"

  license "MIT"

  spec_extras[:metadata] = ->(val) {
    val.merge!({"rubygems_mfa_required" => "true"})
  }

  extra_deps << ["mime-types-data", "~> 3.2025", ">= 3.2025.0507"]
  extra_deps << ["logger", ">= 0"]

  extra_dev_deps << ["hoe", "~> 4.0"]
  extra_dev_deps << ["hoe-halostatue", "~> 2.0"]
  extra_dev_deps << ["hoe-rubygems", "~> 1.0"]
  extra_dev_deps << ["minitest", "~> 5.0"]
  extra_dev_deps << ["minitest-autotest", "~> 1.0"]
  extra_dev_deps << ["minitest-focus", "~> 1.0"]
  extra_dev_deps << ["minitest-hooks", "~> 1.4"]
  extra_dev_deps << ["rake", ">= 10.0", "< 14"]
  extra_dev_deps << ["rdoc", ">= 0.0"]
  extra_dev_deps << ["standard", "~> 1.0"]
end

Minitest::TestTask.create :test
Minitest::TestTask.create :coverage do |t|
  formatters = <<-RUBY.split($/).join(" ")
    SimpleCov::Formatter::MultiFormatter.new([
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::LcovFormatter,
      SimpleCov::Formatter::SimpleFormatter
    ])
  RUBY
  t.test_prelude = <<-RUBY.split($/).join("; ")
  require "simplecov"
  require "simplecov-lcov"

  SimpleCov::Formatter::LcovFormatter.config do |config|
    config.report_with_single_file = true
    config.lcov_file_name = "lcov.info"
  end

  SimpleCov.start "test_frameworks" do
    enable_coverage :branch
    primary_coverage :branch
    formatter #{formatters}
  end
  RUBY
end

task default: :test

namespace :benchmark do
  task :support do
    %w[lib support].each { |path|
      $LOAD_PATH.unshift(File.join(Rake.application.original_dir, path))
    }
  end

  desc "Benchmark Load Times"
  task :load, [:repeats] => "benchmark:support" do |_, args|
    require "benchmarks/load"
    Benchmarks::Load.report(
      File.join(Rake.application.original_dir, "lib"),
      args.repeats
    )
  end

  desc "Memory profiler"
  task :memory, [:top_x, :mime_types_only] => "benchmark:support" do |_, args|
    require "benchmarks/profile_memory"
    Benchmarks::ProfileMemory.report(
      mime_types_only: args.mime_types_only,
      top_x: args.top_x
    )
  end

  desc "Columnar memory profiler"
  task "memory:columnar", [:top_x, :mime_types_only] => "benchmark:support" do |_, args|
    require "benchmarks/profile_memory"
    Benchmarks::ProfileMemory.report(
      columnar: true,
      mime_types_only: args.mime_types_only,
      top_x: args.top_x
    )
  end

  desc "Columnar allocation counts (full load)"
  task "memory:columnar:full", [:top_x, :mime_types_only] => "benchmark:support" do |_, args|
    require "benchmarks/profile_memory"
    Benchmarks::ProfileMemory.report(
      columnar: true,
      full: true,
      top_x: args.top_x,
      mime_types_only: args.mime_types_only
    )
  end

  desc "Object counts"
  task objects: "benchmark:support" do
    require "benchmarks/object_counts"
    Benchmarks::ObjectCounts.report
  end

  desc "Columnar object counts"
  task "objects:columnar" => "benchmark:support" do
    require "benchmarks/object_counts"
    Benchmarks::ObjectCounts.report(columnar: true)
  end

  desc "Columnar object counts (full load)"
  task "objects:columnar:full" => "benchmark:support" do
    require "benchmarks/object_counts"
    Benchmarks::ObjectCounts.report(columnar: true, full: true)
  end
end

namespace :profile do
  task full: "benchmark:support" do
    require "profile"
    profile_full
  end

  task columnar: "benchmark:support" do
    require "profile"
    profile_columnar
  end

  task "columnar:full" => "benchmark:support" do
    require "profile"
    profile_columnar_full
  end
end

namespace :convert do
  namespace :docs do
    task :setup do
      gem "rdoc"
      require "rdoc/rdoc"
      @doc_converter ||= RDoc::Markup::ToMarkdown.new
    end

    FileList["*.rdoc"].each do |name|
      rdoc = name
      mark = "#{File.basename(name, ".rdoc")}.md"

      file mark => [rdoc, :setup] do |t|
        puts "#{rdoc} => #{mark}"
        File.binwrite(t.name, @doc_converter.convert(IO.read(t.prerequisites.first)))
      end

      CLEAN.add mark

      task run: [mark]
    end
  end

  desc "Convert documentation from RDoc to Markdown"
  task docs: "convert:docs:run"
end

task :version do
  require "mime/types/version"
  puts MIME::Types::VERSION
end

namespace :deps do
  task :top, [:number] => "benchmark:support" do |_, args|
    require "deps"
    Deps.run(args)
  end
end

task :console do
  arguments = %w[irb]
  arguments.push(*spec.spec.require_paths.map { |dir| "-I#{dir}" })
  arguments.push("-r#{spec.spec.name.gsub("-", File::SEPARATOR)}")
  unless system(*arguments)
    error "Command failed: #{show_command}"
    abort
  end
end
