require 'dotenv'
require './lib/garbage_collector.rb'

# We might want to extra this in a file to make it easier to edit
projects = [
  { bintray: 'wordpress-mobile/maven/utils', github: 'wordpress-mobile/WordPress-Utils-Android' }
]

Dotenv.load unless ENV['CI']

@bintray_base_url = 'https://bintray.com/api/v1/packages'

def read_from_environment!(key)
  value = ENV[key]
  raise "Missing #{key} environment variable" if value.nil? || value.to_s.empty?
  return value
end

bintray_user = read_from_environment!('BINTRAY_USER')
bintray_key = read_from_environment!('BINTRAY_KEY')

verbose = true
dry_run = false # Use this for debugging

GarbageCollector.new(bintray_user, bintray_key, verbose, dry_run).run(projects)
