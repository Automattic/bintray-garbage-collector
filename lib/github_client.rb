require_relative './json_http_client.rb'

class GitHubClient

  def initialize(base_url: 'https://api.github.com')
    @base_url = base_url
    @json_http_client = JSONHTTPClient.new
  end

  def is_pr_closed?(repo:, pr_id:)
    uri = URI("#{@base_url}/repos/#{repo}/pulls/#{pr_id}")
    json = @json_http_client.get(uri: uri)

    return nil if json.nil?

    json['state'] == 'closed'
  end
end
