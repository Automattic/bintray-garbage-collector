class GarbageCollector

  def initialize(bintray_user, bintray_key)
    @bintray_user = bintray_user
    @bintray_key = bintray_key

    @bintray = BintrayClient.new(bintray_user, bintray_key)
    @github = GitHubClient.new
  end

  def run(projects)
    projects.each do |project|
      versions_to_delete = @bintray.get_bintray_versions(project[:bintray])

      versions_to_delete.each do |pr_id, versions|
        next unless @github.is_pr_closed?(project[:github], pr_id)

        versions.each do |version|
          @bintray.delete_bintray_version(project[:bintray], version)
        end
      end
    end
  end
end
