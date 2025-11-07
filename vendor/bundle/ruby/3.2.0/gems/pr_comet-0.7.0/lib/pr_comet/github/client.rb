# frozen_string_literal: true

class PrComet
  module Github
    # GitHub API Client
    class Client
      attr_reader :repository

      def initialize(access_token, remote_url)
        @client = Octokit::Client.new(access_token: access_token)
        @repository = remote_url.match(REPOSITORY_MATCHER)[:repository]
      end

      # Create a pull request
      #
      # @param base [String] The branch you want your changes pulled into
      # @param head [String] The branch where your changes are implemented
      # @param title [String] Title for the pull request
      # @param body [String] The body for the pull request
      # @return [Integer] Created pull request number
      # @see http://octokit.github.io/octokit.rb/Octokit/Client/PullRequests.html#create_pull_request-instance_method
      def create_pull_request(base:, head:, title:, body:)
        response =
          client.create_pull_request(repository, base, head, title, body)
        response.number
      end

      # Add labels to the issue.
      #
      # @param issue_number [Integer] Number ID of the issue (or pull request)
      # @param labels [Array<String>] An array of labels to apply to this Issue
      # @see http://octokit.github.io/octokit.rb/Octokit/Client/Labels.html#add_labels_to_an_issue-instance_method
      def add_labels(issue_number, *labels)
        client.add_labels_to_an_issue(repository, issue_number, labels)
      end

      # Adds supplied issue (or pull request) to the GitHub project
      #
      # @param issue_number [Integer] Number ID of the issue (or pull request)
      # @param column_name [String] A target column name
      # @param project_id [Integer]
      #   A target project ID. It is a optional parameter. If does not supplied,
      #   this method will find a project which associated the repository.
      #   When the repository has multiple projects, you should supply this.
      # @see http://octokit.github.io/octokit.rb/Octokit/Client/Projects.html#create_project_card-instance_method
      def add_to_project(issue_number, column_name:, project_id: nil)
        project_id ||= default_project_id
        column_id = get_project_column_id(project_id, column_name)
        issue_id = get_issue_id(issue_number)
        client.create_project_card(
          column_id,
          content_id: issue_id,
          content_type: 'PullRequest'
        )
      rescue Octokit::Error => e
        raise "Failed to add a pull request to the project: #{e.message}"
      end

      private

      REPOSITORY_MATCHER = %r{github\.com[:/](?<repository>.+)\.git}.freeze

      attr_reader :client

      # Returns a GitHub project column id which associated with supplied
      # project ID and which matched with supplied column name. If does not
      # found column, it returns nil.
      #
      # @param project_id [Integer] A target project ID
      # @param column_name [String] A target column name
      # @return [Integer, nil] Project column ID
      def get_project_column_id(project_id, column_name)
        find_project_columns(project_id).find { |c| c.name == column_name }.id
      end

      # Returns the issue (or pull request) ID
      #
      # @param issue_number [Integer] A target issue number
      # @return [Integer] Issue ID
      def get_issue_id(issue_number)
        client.pull_request(repository, issue_number).id
      end

      # Finds a project id which associate with this repository.
      # If found multiple projects it returns first one.
      #
      # @return [Integer] Project ID
      # @raise [StandardError] Raises error when does not found a project.
      # @see http://octokit.github.io/octokit.rb/Octokit/Client/Projects.html#projects-instance_method
      def default_project_id
        client.projects(repository).first.id
      end

      # Finds project columns with supplied project ID.
      #
      # @param project_id [Integer] A target project ID
      # @return [Array<Sawyer::Resource>] List of project columns
      # @see http://octokit.github.io/octokit.rb/Octokit/Client/Projects.html#project_columns-instance_method
      def find_project_columns(project_id)
        client.project_columns(project_id)
      end
    end
  end
end
