require "rake"

# inspired by http://robots.thoughtbot.com/test-rake-tasks-like-a-boss
shared_context "rake" do
  let(:rake)      { Rake::Application.new }
  let(:task_name) { rake.parse_task_string(self.class.description).first }
  let(:task_args) { rake.parse_task_string(self.class.description).last }
  let(:task_path) { "lib/tasks" }
  subject         { rake[task_name] }

  def loaded_files_excluding_current_rake_file
    $".reject {|file| file == File.expand_path("#{task_path}.rake", APIPIE_ROOT) }
    ($" - rake_files.map(&File.method(:realpath)))
  end

  def rake_files
    Dir["#{task_path}/**/*.rake"]
  end

  before do
    Rake.application = rake
    rake_files.each do |file|
      Rake.application.rake_require(file.gsub(/.rake$/, ''), [APIPIE_ROOT], loaded_files_excluding_current_rake_file)
    end

    Rake::Task.define_task(:environment)
  end
end
