require "rake"

# inspired by http://robots.thoughtbot.com/test-rake-tasks-like-a-boss
shared_context "rake" do
  let(:rake)      { Rake::Application.new }
  let(:task_name) { rake.parse_task_string(self.class.description).first }
  let(:task_args) { rake.parse_task_string(self.class.description).last }
  let(:task_path) { "lib/tasks/apipie" }
  subject         { rake[task_name] }

  def loaded_files_excluding_current_rake_file
    $".reject {|file| file == File.expand_path("#{task_path}.rake", APIPIE_ROOT) }
  end

  before do
    Rake.application = rake
    Rake.application.rake_require(task_path, [APIPIE_ROOT], loaded_files_excluding_current_rake_file)

    Rake::Task.define_task(:environment)
  end
end
