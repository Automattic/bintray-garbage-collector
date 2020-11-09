require_relative './json_http_client.rb'

class BintrayClient

  def initialize(user:, key:, base_url: 'https://bintray.com/api/v1/packages')
    @base_url = base_url
    @user = user
    @key = key
    @json_http_client = JSONHTTPClient.new
  end

  def get_bintray_versions(project:)
    uri = URI("#{@base_url}/#{project}")
    json = @json_http_client.get(uri: uri)

    return nil if json.nil?

    versions = json['versions']

    return nil if versions.nil?

    return versions
      .select { |v| v =~ /^\d+-.*$/ }
      .group_by { |v| v.split('-').first }
  end

  def delete_bintray_version(project:, version:)
    uri = URI("#{@base_url}/#{project}/versions/#{version}")
    json = @json_http_client.delete(uri: uri)

    return nil if json.nil?

    message = json['message']

    return nil if message.nil?

    return message == 'success'
  end

end
