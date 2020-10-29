require 'net/http'
require 'json'

class BintrayClient

  def initialize(user, key, base_url = 'https://bintray.com/api/v1/packages')
    @base_url = base_url
    @user = user
    @key = key
  end

  def get_bintray_versions(project)
    uri = URI("#{@base_url}/#{project}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)

    response = http.request(request)

    return nil unless response.kind_of? Net::HTTPSuccess

    json = JSON.parse(response.body)

    versions = json['versions']

    return nil if versions.nil?

    return versions
      .select { |v| v =~ /^\d+-.*$/ }
      .group_by { |v| v.split('-').first }
  end

  def delete_bintray_version(project, version)
    uri = URI("#{@base_url}/#{project}/versions/#{version}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Delete.new(uri.request_uri)
    request.basic_auth @user, @key

    response = http.request(request)

    return nil unless response.kind_of? Net::HTTPSuccess

    json = JSON.parse(response.body)

    message = json['message']

    return nil if message.nil?

    return message == 'success'
  end

end
