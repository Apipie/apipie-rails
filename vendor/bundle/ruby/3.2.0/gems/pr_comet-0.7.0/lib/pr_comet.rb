# frozen_string_literal: true

require 'English'
require 'octokit'
require 'rainbow'
require 'pr_comet/version'
require 'pr_comet/errors'
require 'pr_comet/command_line'
require 'pr_comet/git/command'
require 'pr_comet/github/client'

# Helps to create a pull request
class PrComet
  # @note You have to set ENV['GITHUB_ACCESS_TOKEN']
  # @param base [String] The branch you want your changes pulled into
  # @param branch [String] The branch where your changes are going to implement.
  # @param user_name [String] The username to use for committer and author
  # @param user_email [String] The email to use for committer and author
  # @param verbose [Boolean] Displays executing commands
  def initialize(base:, branch:, user_name: nil, user_email: nil, verbose: false)
    raise "You have to set ENV['GITHUB_ACCESS_TOKEN']" if access_token.nil?

    @base_branch = base
    @topic_branch = branch
    @git = Git::Command.new(user_name: user_name, user_email: user_email, verbose: verbose)
    @github = Github::Client.new(access_token, git.remote_url('origin'))
    @initial_sha1 = git.current_sha1
  end

  # Add and commit local files to this branch
  #
  # @param message [String] The commit message
  # @yield Some commands where modify local files
  # @return [Object] Return result of yield if you use &block
  # @raise [RubocopChallenger::Errors::ExistUncommittedModify]
  #        Raise error if you use &block and exists someuncommitted files
  def commit(message, &block)
    git.checkout_with(topic_branch) unless git.current_branch?(topic_branch)
    result = modify_files(&block) if block_given?
    git.add('.')
    git.commit(message)
    result
  rescue PrComet::Errors::ExistUncommittedModify
    raise `git status`
  end

  # Create a pull request. You should call #commit before calling this method.
  # If you want to create a blank PR, you can do it with `validate: false`
  # option.
  #
  # @param options [Hash]
  #   Options for the PR creation.
  # @option title [String]
  #   The title for the pull request
  # @option body [String]
  #   The body for the pull request
  # @option labels [Array<String>]
  #   List of labels. It is a optional parameter. You can add labels to the
  #   created PR.
  # @option project_column_name [String]
  #   A project column name. It is a optional parameter. You can add the created
  #   PR to the GitHub project.
  # @option project_id [Integer]
  #   A target project ID. It is a optional parameter. If does not supplied,
  #   this method will find a project which associated the repository.
  #   When the repository is associated with multiple projects, you should
  #   supply this.
  # @option validate [Boolean]
  #   Verifies the branch has commits and checkout to the topic branch. If you
  #   want to create a blank PR, set "false" to this option. default: true.
  # @return [Boolean]
  #   Return true if it is successed.
  # rubocop:disable Metrics/AbcSize
  def create!(**options)
    options[:validate] = true if options[:validate].nil?
    return false if options[:validate] && !git_condition_valid?

    git.push(github_token_url, topic_branch)
    pr_number = github.create_pull_request(**generate_create_pr_options(**options))
    github.add_labels(pr_number, *options[:labels]) unless options[:labels].nil?
    unless options[:project_column_name].nil?
      github.add_to_project(pr_number, **generate_add_to_project_options(**options))
    end
    true
  end
  # rubocop:enable Metrics/AbcSize

  private

  attr_reader :git, :github, :base_branch, :topic_branch, :initial_sha1

  def generate_create_pr_options(**options)
    {
      base: base_branch,
      head: topic_branch,
      title: options[:title],
      body: options[:body]
    }
  end

  def generate_add_to_project_options(**options)
    {
      column_name: options[:project_column_name],
      project_id: options[:project_id]
    }
  end

  def git_condition_valid?
    !git.current_sha1?(initial_sha1) && git.current_branch?(topic_branch)
  end

  def modify_files
    raise Errors::ExistUncommittedModify if git.exist_uncommitted_modify?

    yield
  end

  def access_token
    ENV['GITHUB_ACCESS_TOKEN']
  end

  # @note You *MUST NOT* use `#access_token` in the URL because this string
  #       will be output STDOUT via `RubocopChallenger::CommandLine` module.
  def github_token_url
    "https://${GITHUB_ACCESS_TOKEN}@github.com/#{github.repository}"
  end
end
