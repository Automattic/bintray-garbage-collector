require 'dotenv'
require 'net/http'
require 'json'

# We might want to extra this in a file to make it easier to edit
projects = [
  { bintray: 'mokagio/maven/utils-experiment', github: 'mokagio/WordPress-Utils-Android' }
]

Dotenv.load unless ENV['CI']

@bintray_base_url = 'https://bintray.com/api/v1/packages'

def read_from_environment!(key)
  value = ENV[key]
  raise "Missing #{key} environment variable" if value.nil? || value.to_s.empty?
end

@bintray_user = read_from_environment!('BINTRAY_USER')
@bintray_key = read_from_environment!('BINTRAY_KEY')

def get_bintray_versions(project)
  uri = URI("#{@bintray_base_url}/#{project}")
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
  uri = URI("#{@bintray_base_url}/#{project}/versions/#{version}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  request = Net::HTTP::Delete.new(uri.request_uri)
  request.basic_auth @bintray_user, @bintray_key

  http.request(request)
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

projects.each do |project|
  # "Fancy" functional-ish version, with no option for logging...
  #
  # extract_development_versions(get_bintray_versions(project[:bintray]))
  #   .select { |pr_id, _| get_pr_state(project[:github], pr_id) == 'closed' }
  #   .values
  #   .flatten
  #   .each do |version|
  #     delete_bintray_version(project[:bintray], version)
  #   end

  puts "Checking binaries for #{project[:bintray]} from GitHub #{project[:github]}."

  versions = extract_development_versions(get_bintray_versions(project[:bintray]))
  puts "Found binaries for PRs #{versions.keys.join(', ')}"

  versions_to_delete = versions.select { |pr_id, _| get_pr_state(project[:github], pr_id) == 'closed' }

  versions_to_delete.each do |pr_id, binaries|
    puts "Deleting binaries for closed PR #{pr_id}"
    binaries.each do |binary|
      puts "Deleting binary #{binary}"
      delete_bintray_version(project[:bintray], binary)
    end
  end
end
