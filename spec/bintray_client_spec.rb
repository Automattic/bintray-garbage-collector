require 'bintray_client'
require 'json'
require 'net/http'

RSpec.describe BintrayClient do

  let(:base_url) { 'https://test.com' }
  let(:package) { 'package_name' }

  describe 'requesting the version for a package' do

    context 'when the request is successful' do

      it 'returns only the development versions keyed by PR number' do
        response_versions = [
          '1.2.3',
          '1-abcdef',
          '1-bcdef0',
          '2.0.0-beta.1',
          'a-string-version',
          '2-cdef01',
        ]
        stub_request(:get, "#{base_url}/#{package}")
          .to_return(status: 200, body: get_package_response(response_versions))

        client = BintrayClient.new('user', 'key', base_url)
        versions = client.get_bintray_versions('package_name')

        expect(versions).to eq({
          '1' => ['1-abcdef', '1-bcdef0'],
          '2' => ['2-cdef01']
        })
      end

      context 'when the response body has no version key' do

        it 'returns nil' do
          stub_request(:get, "#{base_url}/#{package}")
            .to_return(status: 200, body: { foo: 'bar' }.to_json)

          client = BintrayClient.new('user', 'key', base_url)
          versions = client.get_bintray_versions('package_name')

          expect(versions).to be_nil
        end
      end
    end

    context 'when the request fails' do

      it 'returns nil' do
        stub_request(:get, "#{base_url}/#{package}")
          .to_return(status: 400)

        client = BintrayClient.new('user', 'key', base_url)
        versions = client.get_bintray_versions('package_name')

        expect(versions).to be_nil
      end
    end
  end

  describe 'deleting a package version' do

    let(:version) { 'version-name' }

    context 'when the request is successful' do

      it 'returns true' do
        # See https://www.jfrog.com/confluence/display/BT/Bintray+REST+API#BintrayRESTAPI-DeleteVersion
        stub_request(:delete, "#{base_url}/#{package}/versions/#{version}")
          .to_return(status: 200, body: { message: 'success' }.to_json)

        client = BintrayClient.new('user', 'key', base_url)
        result = client.delete_bintray_version('package_name', version)

        expect(result).to be_truthy
      end
    end

    context 'when the response body has an error' do

      it 'returns false' do
        # See https://www.jfrog.com/confluence/display/BT/Bintray+REST+API#BintrayRESTAPI-DeleteVersion
        stub_request(:delete, "#{base_url}/#{package}/versions/#{version}")
          .to_return(status: 200, body: { message: 'some error' }.to_json)

        client = BintrayClient.new('user', 'key', base_url)
        result = client.delete_bintray_version('package_name', version)

        expect(result).to be_falsy
      end
    end

    context 'when the response body has no message' do

      it 'returns false' do
        stub_request(:delete, "#{base_url}/#{package}/versions/#{version}")
          .to_return(status: 200, body: { foo: 'bar' }.to_json)

        client = BintrayClient.new('user', 'key', base_url)
        result = client.delete_bintray_version('package_name', version)

        expect(result).to be_falsy
      end
    end

    context 'when the request fails' do

      it 'returns false' do
        # See https://www.jfrog.com/confluence/display/BT/Bintray+REST+API#BintrayRESTAPI-DeleteVersion
        stub_request(:delete, "#{base_url}/#{package}/versions/#{version}")
          .to_return(status: 400)

        client = BintrayClient.new('user', 'key', base_url)
        result = client.delete_bintray_version('package_name', version)

        expect(result).to be_falsy
      end
    end
  end

  it 'can initialize without an explicit base_url value' do
    client = BintrayClient.new('user', 'key')
    expect(client).to_not be_nil
  end
end

def get_package_response(versions)
  # See https://www.jfrog.com/confluence/display/BT/Bintray+REST+API#BintrayRESTAPI-GetPackage
  %Q{
{
  "name": "my-package",
  "repo": "repo",
  "owner": "user",
  "desc": "This package...",
  "labels": ["persistence", "database"],
  "attribute_names": ["licenses", "vcs", "github"],
  "licenses": ["Apache-2.0"],
  "followers_count": 82,
  "created": "ISO8601 (yyyy-MM-dd'T'HH:mm:ss.SSSZ)",
  "website_url": "http://jfrog.com",
  "rating": 8,
  "issue_tracker_url": "https://github.com/bintray/bintray-client-java/issues",
  "linked_to_repos": [],
  "github_repo": "",
  "github_release_notes_file": "",
  "public_download_numbers": false,
  "public_stats": true,
  "permissions": [],
  "versions": #{versions},
  "latest_version": "1.2.5",
  "rating_count": 8,
  "system_ids" : [],
  "updated": "ISO8601 (yyyy-MM-dd'T'HH:mm:ss.SSSZ)",
  "vcs_url": "https://github.com/bintray/bintray-client-java.git"
}
  }
end
