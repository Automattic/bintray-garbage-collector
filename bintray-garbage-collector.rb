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

projects = [
  'mokagio/maven/utils-experiment'
]

projects.each do |project|
  puts get_bintray_versions(project)
end
