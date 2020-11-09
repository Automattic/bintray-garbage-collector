require 'net/http'
require 'json'

class JSONHTTPClient

  def get(uri:)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    return nil unless response.kind_of? Net::HTTPSuccess

    JSON.parse(response.body)
  end

  def delete(uri:)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Delete.new(uri.request_uri)
    request.basic_auth @user, @key

    response = http.request(request)

    return nil unless response.kind_of? Net::HTTPSuccess

    JSON.parse(response.body)
  end
end
