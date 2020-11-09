require_relative './json_http_client.rb'

# +BintrayClient+ interfaces with the Bintray REST API
#
# @see https://www.jfrog.com/confluence/display/BT/Bintray+REST+API
class BintrayClient

  # A new instance of +BintrayClient+
  #
  # @param user [String] the username to use to authenticate with the Bintray API
  # @param key [String] the key to use to authenticate with the Bintray API
  # @param base_url [String] the base URL to use when calling the Bintray API
  def initialize(user:, key:, base_url: 'https://bintray.com/api/v1/packages')
    @base_url = base_url
    @json_http_client = JSONHTTPClient.new
    @auth = HTTPBasicAuth.new(user: user, password: key)
  end

  # Requests the development versions, those automatically generated from GitHub pull requests, for a given project on Bintray
  #
  # @param project [String] the name of the project on Bintray
  # @return [Hash] an hash of development versions, keyed by the id of the PR that generated them, where every value is an array of +String+ with the matching versions; or nil if the request fails
  # @see https://www.jfrog.com/confluence/display/BT/Bintray+REST+API#BintrayRESTAPI-GetPackage
  def get_bintray_versions(project:)
    uri = URI("#{@base_url}/#{project}")
    json = @json_http_client.get(uri: uri)

    return nil if json.nil?

    versions = json['versions']

    return nil if versions.nil?

    # The format for the development version doesn't follow semantic version.
    # It is "<PR id>-<commit SHA>".
    #
    # See https://github.com/wordpress-mobile/WordPress-Utils-Android/pull/40
    # for an example implementation.
    return versions
      .select { |v| v =~ /^\d+-.*$/ }
      .group_by { |v| v.split('-').first }
  end

  # Deletes the given version from the given project on Bintray
  #
  # @param project [String] the name of the project on Bintray
  # @param version [String] the version to delete from +project+
  # @return [Bool] whether the deletion succeeded or +nil+ if the request failed
  # @see https://www.jfrog.com/confluence/display/BT/Bintray+REST+API#BintrayRESTAPI-DeleteVersion
  def delete_bintray_version(project:, version:)
    uri = URI("#{@base_url}/#{project}/versions/#{version}")
    json = @json_http_client.delete(uri: uri, auth: @auth)

    return nil if json.nil?

    message = json['message']

    return nil if message.nil?

    return message == 'success'
  end

end
