require 'dotenv'
require_relative '../lib/garbage_collector.rb'

# We might want to extract this in a file to make it easier to edit
projects = [
  { bintray: 'wordpress-mobile/maven/utils', github: 'wordpress-mobile/WordPress-Utils-Android' }
]

Dotenv.load

def read_from_environment!(key)
  value = ENV[key]
  message = "Missing #{key} environment variable. If you are running this locally, consider setting up a .env file using .env.sample as a starting point"
  raise message if value.nil? || value.to_s.empty?
  return value
end

GarbageCollector.new(
  bintray_user: read_from_environment!('BINTRAY_USER'),
  bintray_key: read_from_environment!('BINTRAY_KEY'),
  verbose: true,
  dry_run: false
).run(projects)
