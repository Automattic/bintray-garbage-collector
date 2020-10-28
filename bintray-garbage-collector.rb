require 'net/http'
require 'json'

def get_bintray_versions(project)
  uri = URI("https://bintray.com/api/v1/packages/#{project}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)
  json = JSON.parse(response.body)

  json['versions']
end

def extract_development_versions(versions)
  versions
    .select { |v| v =~ /\d+-.*/ }
    .group_by { |v| v.split('-').first }
end

def delete_bintray_version(project, version)
  puts "TODO: Make API call to delete #{version} for #{project}"
end

def get_pr_state(repo, id)
  uri = URI("https://api.github.com/repos/#{repo}/pulls/#{id}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Get.new(uri.request_uri)

  response = http.request(request)
  json = JSON.parse(response.body)

  json['state']
end

projects = [
  { bintray: 'mokagio/maven/utils-experiment', github: 'mokagio/WordPress-Utils-Android' }
]

projects.each do |project|
  extract_development_versions(get_bintray_versions(project[:bintray])).each do |pr_id, binaries|
    next unless get_pr_state(project[:github], pr_id) == 'closed'
    binaries.each do |version|
      delete_bintray_version(project[:bintray], version)
    end
  end
end
