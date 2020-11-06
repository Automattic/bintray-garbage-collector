require_relative './http_client.rb'

class GitHubClient

  def initialize(base_url: 'https://api.github.com')
    @base_url = base_url
    @http_client = HTTPClient.new
  end

  def is_pr_closed?(repo:, pr_id:)
    uri = URI("#{@base_url}/repos/#{repo}/pulls/#{pr_id}")
    json = @http_client.get_json(uri: uri)

    return nil if json.nil?

    json['state'] == 'closed'
  end
end
