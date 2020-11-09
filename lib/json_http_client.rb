require_relative './http_basic_auth.rb'
require 'net/http'
require 'json'

# +JSONHTTPClient+ makes HTTP request to endpoint that should respond with a JSON and returns the parsed response
class JSONHTTPClient

  # Executes a GET request to a the given JSON endpoint
  #
  # @param uri [URI] the uri to make the request to
  def get(uri:)
    execute(request_class: Net::HTTP::Get, uri: uri)
  end

  # Executes a DELETE request to a the given JSON endpoint
  #
  # @param uri [URI] the uri to make the request to
  # @param auth [HTTPBasicAuth] the HTTP basic authentication credentials
  def delete(uri:, auth:)
    execute(request_class: Net::HTTP::Delete, uri: uri, auth: auth)
  end

  private

  # Executes a request of the given type to a the given JSON endpoint with optional HTTP basic authentication
  #
  # @param request_class [Net::HTTP class] the +Net::HTTP+ class to use for the request, e.g. +Net::HTTP::Get+
  # @param uri [URI] the uri to make the request to
  # @param auth [HTTPBasicAuth] the HTTP basic authentication credentials
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
