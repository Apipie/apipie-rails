# frozen_string_literal: true

require 'thor'

module RubocopChallenger
  # To define CLI commands
  class CLI < Thor
    desc 'go', 'Run `$ rubocop --autocorrect` and create a PR to GitHub repo'
    option :email,
           required: true,
           type: :string,
           desc: 'The Pull Request committer email'
    option :name,
           required: true,
           type: :string,
           desc: 'The Pull Request committer name'
    option :file_path,
           type: :string,
           default: '.rubocop_todo.yml',
           aliases: :f,
           desc: 'Set your ".rubocop_todo.yml" path'
    option :template,
           type: :string,
           aliases: :t,
           desc: 'A Pull Request template `erb` file path.' \
                 'You can use variable that `title`, `rubydoc_url`, ' \
                 '`description` and `examples` into the erb file.'
    option :mode,
           type: :string,
           default: 'most_occurrence',
           desc: 'Mode to select deletion target. You can choice ' \
                 '"most_occurrence", "least_occurrence", or "random". ' \
                 'If you set --no-offense-counts, the mode to be forced to "random".'
    option :base_branch,
           type: :string,
           default: 'master',
           aliases: :b,
           desc: 'The Branch to merge into'
    option :labels,
           type: :array,
           default: ['rubocop challenge'],
           aliases: :l,
           desc: 'Label to give to Pull Request'
    option :project_column_name,
           type: :string,
           desc: 'A project column name. You can add the created PR to the ' \
                 'GitHub project'
    option :project_id,
           type: :numeric,
           desc: 'A target project ID. If does not supplied, this method ' \
                 'will find a project which associated the repository. When ' \
                 'the repository has multiple projects, you should supply this.'
    option :create_pr,
           type: :boolean,
           default: true,
           desc: 'If you set --no-create-pr, no create a pull request (for testing)'
    option :exclude_limit,
           type: :numeric,
           desc: 'For how many exclude properties on create .rubocop_todo.yml'
    option :auto_gen_timestamp,
           type: :boolean,
           default: true,
           desc: 'Include the date and time in .rubocop_todo.yml'
    option :offense_counts,
           type: :boolean,
           default: true,
           desc: 'Include offense counts in .rubocop_todo.yml'
    option :only_safe_autocorrect,
           type: :boolean,
           default: false,
           desc: 'If given `true`, it executes `rubocop --autocorrect`,' \
                 'it means to correct safe cops only.'
    option :only_exclude,
           type: :boolean,
           default: false,
           desc: 'If you set --only-exclude, exclude files instead of generating Max parameters ' \
                 'in Metrics cops when creating .rubocop_todo.yml automatically.'
    option :verbose,
           type: :boolean,
           default: false,
           desc: 'Displays executing command.'
    def go
      Go.new(options).exec
    rescue Errors::NoAutoCorrectableRule => e
      puts Rainbow(e.message).yellow
    rescue StandardError => e
      puts Rainbow(e.message).red
      exit_process!
    end

    desc 'version', 'Show current version'
    def version
      puts RubocopChallenger::VERSION
    end

    # Workaround to return exit code 1 when an error occurs
    # @see https://github.com/erikhuda/thor/issues/244
    def self.exit_on_failure?
      true
    end

    private

    # Exit process (Mainly for mock when testing)
    def exit_process!
      abort
    end
  end
end
