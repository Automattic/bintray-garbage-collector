require 'bintray_client'
require 'json'
require 'net/http'

RSpec.describe BintrayClient do

  describe 'requesting the version for a package' do

    context 'when the request is successful' do

      it 'returns only the development versions keyed by PR number' do
        base_url = 'https://test.com'
        package = 'package_name'
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

        client = BintrayClient.new(base_url)
        versions = client.get_bintray_versions('package_name')

        expect(versions).to eq({
          '1' => ['1-abcdef', '1-bcdef0'],
          '2' => ['2-cdef01']
        })
      end
    end

    it 'can initialize without an explicit base_url value' do
      client = BintrayClient.new
      expect(client).to_not be_nil
    end
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
