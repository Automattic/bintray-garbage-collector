require 'dotenv'
require 'optparse'
require 'psych'
require_relative '../lib/garbage_collector.rb'

source = Psych.load(File.read('projects.yml'), symbolize_names: true)
projects = source[:projects]

Dotenv.load

# Default options
options = {
  verbose: true,
  dry_run: false
}

OptionParser.new do |parser|
  parser.banner = "Usage: #{File.basename(__FILE__)} [options]"

  parser.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end

  parser.on('-d', '--dry-run', "Dry run") do
    options[:dry_run] = true
  end
end.parse!

def read_from_environment!(key)
  value = ENV[key]
  message = "Missing #{key} environment variable. If you are running this locally, consider setting up a .env file using .env.sample as a starting point"
  raise message if value.nil? || value.to_s.empty?
  return value
end

GarbageCollector.new(
  bintray_user: read_from_environment!('BINTRAY_USER'),
  bintray_key: read_from_environment!('BINTRAY_KEY'),
  verbose: options[:verbose],
  dry_run: options[:dry_run]
).run(projects)
