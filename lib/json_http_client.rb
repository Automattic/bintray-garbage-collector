require_relative './http_basic_auth.rb'
require 'net/http'
require 'json'

class JSONHTTPClient

  def get(uri:)
    execute(request_class: Net::HTTP::Get, uri: uri)
  end

  def delete(uri:, auth:)
    execute(request_class: Net::HTTP::Delete, uri: uri, auth: auth)
  end

  private

  def execute(request_class:, uri:, auth: nil)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = request_class.new(uri.request_uri)
    request.basic_auth(auth.user, auth.password) unless auth.nil?

    response = http.request(request)

    return nil unless response.kind_of? Net::HTTPSuccess

    JSON.parse(response.body)
  end
end
