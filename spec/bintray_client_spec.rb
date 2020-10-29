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
