require 'net/http'
require 'json'

class BintrayClient

  def initialize(base_url = 'https://bintray.com/api/v1/packages')
    @base_url = base_url
  end

  def get_bintray_versions(project)
    uri = URI("#{@base_url}/#{project}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)
    json = JSON.parse(response.body)

    json['versions']
      .select { |v| v =~ /^\d+-.*$/ }
      .group_by { |v| v.split('-').first }
  end
end
