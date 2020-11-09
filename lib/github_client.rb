require_relative './json_http_client.rb'

# +GitHubClient+ interfaces with the GitHub REST API.
#
# @see https://docs.github.com/en/free-pro-team@latest/rest
class GitHubClient

  # A new instance of +GitHubClient+
  #
  # @param base_url [String] the base URL to use when calling the GitHub API
  def initialize(base_url: 'https://api.github.com')
    @base_url = base_url
    @json_http_client = JSONHTTPClient.new
  end

  # Checks whether the given pull request in the given repository is closed
  #
  # @param repo [String] the name of the GitHub repository with the "org/name" format, e.g. "Automattic/bintray-garbage-collector"
  # @param pr_id [Integer] the pull request id
  # @return [Bool] whether the pull request is closed or nil if the request fails
  # @see https://docs.github.com/en/free-pro-team@latest/rest/reference/pulls#get-a-pull-request
  def is_pr_closed?(repo:, pr_id:)
    uri = URI("#{@base_url}/repos/#{repo}/pulls/#{pr_id}")
    json = @json_http_client.get(uri: uri)

    return nil if json.nil?

    json['state'] == 'closed'
  end
end
