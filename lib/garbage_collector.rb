require_relative 'bintray_client'
require_relative 'github_client'

class GarbageCollector

  def initialize(bintray_user:, bintray_key:, verbose: false, dry_run: false)
    @bintray_user = bintray_user
    @bintray_key = bintray_key
    @verbose = verbose
    @dry_run = dry_run

    @bintray = BintrayClient.new(user: bintray_user, key: bintray_key)
    @github = GitHubClient.new
  end

  def run(projects)
    projects.each do |project|
      log "Looking for versions to delete for #{project[:bintray]}..."

      dev_versions = @bintray.get_bintray_versions(project: project[:bintray])

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
  end

  private

  def log(message)
    puts message if @verbose
  end
end
