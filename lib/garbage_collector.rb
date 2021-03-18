require_relative 'bintray_client'
require_relative 'github_client'

# +GarbageCollector+ is responsible for deleting all the versions of Bintray packages that belong GitHub pull requests that have been closed or merged
class GarbageCollector

  # A new instance of +GarbageCollector+
  #
  # @param bintray_user [String] the username to use to authenticate with Bintray
  # @param bintray_key [String] the key to use to authenticate with Bintray
  # @param verbose [Bool] whether to print information on the process execution to STDOUT
  # @param dry_run [Bool] whether to execute or simulate distructive operations such as deleting versions from Bintray; useful when debugging
  def initialize(bintray_user:, bintray_key:, verbose: false, dry_run: false)
    @bintray_user = bintray_user
    @bintray_key = bintray_key
    @verbose = verbose
    @dry_run = dry_run

    @bintray = BintrayClient.new(user: bintray_user, key: bintray_key)
    @github = GitHubClient.new
  end

  # Runs the garbage collection on the given array of projects
  #
  # @param projects [Array] the array of +Hash+ projects on which to run the garbage collection
  def run(projects)
    projects_not_found = []

    projects.each do |project|
      log "Looking for versions to delete for #{project[:bintray]}..."

      dev_versions = @bintray.get_bintray_versions(project: project[:bintray])

      if dev_versions.nil?
        log "> Project not found."
        projects_not_found.push(project)
        next
      end

      if dev_versions.empty?
        log "> No versions found. Moving on."
        next
      end

      log "> Found versions for PR(s): #{dev_versions.keys.join(', ')}."

      dev_versions.each do |pr_id, versions|
        log "Checking if versions for PR #{pr_id} should be deleted..."

        if @github.is_pr_closed?(repo: project[:github], pr_id: pr_id)
          log "Deleting versions for PR #{pr_id}..."
        else
          log "> PR #{pr_id} is open. Skipping."
          next
        end

        versions.each do |version|
          if @dry_run
            log "> DRY RUN: Would have deleted version #{version}."
            next
          end

          if @bintray.delete_bintray_version(project: project[:bintray], version: version)
            log "> Deleted version #{version}."
          else
            log "> Failed to delete version #{version}."
          end
        end
      end
    end

    unless projects_not_found.empty?
      log("\nGarbage collection was unsuccessful. Could not find projects:", forced: true)
      projects_not_found.each { |p| log("> #{p[:bintray]}", forced: true) }
      exit 1
    end
  end

  private

  def log(message, forced: false)
    puts message if @verbose || forced
  end
end
