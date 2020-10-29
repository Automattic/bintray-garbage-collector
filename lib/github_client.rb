require 'net/http'
require 'json'

class GitHubClient

  def initialize(base_url = 'https://api.github.com')
    @base_url = base_url
  end

  def is_pr_closed?(repo, id)
    uri = URI("#{@base_url}/repos/#{repo}/pulls/#{id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    return nil unless response.kind_of? Net::HTTPSuccess

    json = JSON.parse(response.body)

    json['state'] == 'closed'
  end
end
