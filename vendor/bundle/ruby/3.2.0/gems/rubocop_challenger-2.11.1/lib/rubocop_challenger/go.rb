# frozen_string_literal: true

module RubocopChallenger
  # Executes Rubocop Challenge flow
  class Go
    # @param options [Hash]
    #   Options for the rubocop challenge
    # @option exclude-limit [Integer]
    #   For how many exclude properties on create .rubocop_todo.yml
    # @option auto-gen-timestamp [Boolean]
    #   Include the date and time in .rubocop_todo.yml
    # @option offense_counts [Boolean]
    #   Include offense counts in .rubocop_todo.yml'
    # @option only-safe-autocorrect [Boolean]
    #   If given `true`, it executes `rubocop --autocorrect`,
    #   it means to correct safe cops only.
    # @option name [String]
    #   The author name which use at the git commit
    # @option email [String]
    #   The email address which use at the git commit
    # @option labels [Array<String>]
    #   Will create a pull request with the labels
    # @option no-create-pr [Boolean]
    #   Does not create a pull request when given `true`
    # @option project_column_name [String]
    #   A project column name. You can add the created PR to the GitHub project
    # @option project_id [Integer]
    #   A target project ID. If does not supplied, this method will find a
    #   project which associated the repository. When the repository has
    #   multiple projects, you should supply this.
    # @option verbose [Boolean]
    #   Displays executing command.
    def initialize(options)
      @options = options
    end

    # Executes Rubocop Challenge flow
    #
    # @raise [Errors::NoAutoCorrectableRule]
    #   Raises if there is no auto correctable rule in ".rubocop_todo.yml"
    def exec
      update_rubocop!
      before_version, after_version = regenerate_rubocop_todo!
      corrected_rule = rubocop_challenge!(before_version, after_version)
      regenerate_rubocop_todo!
      add_to_ignore_list_if_challenge_is_incomplete(corrected_rule)
      create_pull_request!(corrected_rule)
    end

    private

    attr_reader :options

    def pull_request
      @pull_request ||= PullRequest.new(**pull_request_options)
    end

    # Executes `$ bundle update` for the rubocop and the associated gems
    def update_rubocop!
      bundler = Bundler::Command.new(verbose: options[:verbose])
      pull_request.commit! ':police_car: $ bundle update rubocop' do
        bundler.update(*RUBOCOP_GEMS)
      end
    end

    # Re-generate .rubocop_todo.yml and run git commit.
    #
    # @return [Array<String>]
    #  Returns the versions of RuboCop which created ".rubocop_todo.yml" before
    #  and after re-generate.
    def regenerate_rubocop_todo!
      before_version = scan_rubocop_version_in_rubocop_todo_file
      pull_request.commit! ':police_car: regenerate rubocop todo' do
        Rubocop::Command.new.auto_gen_config(**auto_gen_config_options)
      end
      after_version = scan_rubocop_version_in_rubocop_todo_file

      [before_version, after_version]
    end

    # @return [String] The version of RuboCop which created ".rubocop_todo.yml"
    def scan_rubocop_version_in_rubocop_todo_file
      Rubocop::TodoReader.new(options[:file_path]).version
    end

    # Run rubocop challenge.
    #
    # @param before_version [String]
    #   The version of RuboCop which created ".rubocop_todo.yml" before
    #   re-generate.
    # @param after_version [String]
    #   The version of RuboCop which created ".rubocop_todo.yml" after
    #   re-generate
    # @return [Rubocop::Rule]
    #   The corrected rule
    # @raise [Errors::NoAutoCorrectableRule]
    #   Raises if there is no auto correctable rule in ".rubocop_todo.yml"
    def rubocop_challenge!(before_version, after_version)
      Rubocop::Challenge.exec(**rubocop_challenge_options).tap do |rule|
        pull_request.commit! ":police_car: #{rule.title}"
      end
    rescue Errors::NoAutoCorrectableRule => e
      create_another_pull_request!(before_version, after_version)
      raise e
    end

    # Creates a pull request for the Rubocop Challenge
    #
    # @param corrected_rule [Rubocop::Rule] The corrected rule
    def create_pull_request!(corrected_rule)
      pull_request.create_rubocop_challenge_pr!(
        corrected_rule, options[:template]
      )
    end

    # Creates a pull request which re-generate ".rubocop_todo.yml" with new
    # version RuboCop. Use this method if it does not need to make a challenge
    # but ".rubocop_todo.yml" is out of date. If same both `before_version` and
    # `after_version`, it does not work.
    #
    # @param before_version [String]
    #   The version of RuboCop which created ".rubocop_todo.yml" before
    #   re-generate.
    # @param after_version [String]
    #   The version of RuboCop which created ".rubocop_todo.yml" after
    #   re-generate
    def create_another_pull_request!(before_version, after_version)
      return if before_version == after_version

      pull_request.create_regenerate_todo_pr!(before_version, after_version)
    end

    DESCRIPTION_THAT_CHALLENGE_IS_INCOMPLETE = <<~MSG
      Rubocop Challenger has executed autocorrecting but it is incomplete.
      Therefore the rule add to ignore list.
    MSG

    # If still exist the rule after a challenge, the rule regard as cannot
    # correct automatically then add to ignore list and it is not chosen as
    # target rule from next time.
    #
    # @param rule [Rubocop::Rule] The corrected rule
    def add_to_ignore_list_if_challenge_is_incomplete(rule)
      return unless autocorrect_incomplete?(rule)

      pull_request.commit! ':police_car: add the rule to the ignore list' do
        config_editor = Rubocop::ConfigEditor.new
        config_editor.add_ignore(rule)
        config_editor.save
      end
      puts Rainbow(DESCRIPTION_THAT_CHALLENGE_IS_INCOMPLETE).yellow
    end

    # Checks the challenge result. If the challenge is successed, the rule
    # should not exist in the ".rubocop_todo.yml" after regenerate.
    #
    # @param rule [Rubocop::Rule] The corrected rule
    # @return [Boolean] Return true if the challenge successed
    def autocorrect_incomplete?(rule)
      todo_reader = Rubocop::TodoReader.new(options[:file_path])
      todo_reader.all_rules.include?(rule)
    end

    def rubocop_challenge_options
      {
        file_path: options[:file_path],
        mode: mode,
        only_safe_autocorrect: options[:only_safe_autocorrect]
      }
    end

    def pull_request_options
      {
        user_name: options[:name],
        user_email: options[:email],
        base_branch: options[:base_branch],
        labels: options[:labels],
        dry_run: !options[:create_pr],
        project_column_name: options[:project_column_name],
        project_id: options[:project_id],
        verbose: options[:verbose]
      }
    end

    def auto_gen_config_options
      {
        exclude_limit: options[:exclude_limit],
        auto_gen_timestamp: options[:auto_gen_timestamp],
        offense_counts: options[:offense_counts],
        only_exclude: options[:only_exclude]
      }
    end

    # Mode to select deletion target.
    # If you set --no-offense-counts, the mode to be forced to "random".
    #
    # @return [String] "most_occurrence", "least_occurrence", or "random"
    def mode
      return 'random' unless options[:offense_counts]

      options[:mode]
    end
  end
end
