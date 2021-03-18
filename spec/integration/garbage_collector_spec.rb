require 'garbage_collector'

RSpec.describe GarbageCollector do

  it 'fails gracefully when a Bintray project cannot be found' do
    gb = GarbageCollector.new(bintray_user: 'user', bintray_key: 'key')
    projects = [
      { bintray: 'bt_project_name_1', github: 'gh_project_name_1' },
    ]

    expect_any_instance_of(BintrayClient).to receive(:get_bintray_versions)
      .and_return(nil)

    gb.run(projects)
  end

  it 'requests to delete all the Bintray version for closed PRs' do
    gb = GarbageCollector.new(bintray_user: 'user', bintray_key: 'key')
    projects = [
      { bintray: 'bt_project_name_1', github: 'gh_project_name_1' },
      { bintray: 'bt_project_name_2', github: 'gh_project_name_2' },
    ]

    # This verifies it deletes _all_ the versions for a closed PR
    #
    # Make bt_project_name_1 have one version
    expect_any_instance_of(BintrayClient).to receive(:get_bintray_versions)
      .with(project: 'bt_project_name_1')
      .and_return({ '1' => ['1-abcdef', '1-bcdef0'] })
    # Make the PR for the matching project with id 1 be closed
    expect_any_instance_of(GitHubClient).to receive(:is_pr_closed?)
      .with(repo: 'gh_project_name_1', pr_id: '1')
      .and_return(true)
    # Ensure that all versions for that PR are deleted
    expect_any_instance_of(BintrayClient).to receive(:delete_bintray_version)
      .with(project: 'bt_project_name_1', version: '1-abcdef')
      .and_return(true)
    expect_any_instance_of(BintrayClient).to receive(:delete_bintray_version)
      .with(project: 'bt_project_name_1', version: '1-bcdef0')
      .and_return(true)

    # This verifies it deletes _only_ versions for closed PRs
    #
    # Make bt_project_name_2 have versions for different PRs
    expect_any_instance_of(BintrayClient).to receive(:get_bintray_versions)
      .with(project: 'bt_project_name_2')
      .and_return({ '2' => ['2-abcdef'], '3' => ['3-bcdef0'] })
    # Make the PRs for the matching project with id 2 be closed and with 3 open
    expect_any_instance_of(GitHubClient).to receive(:is_pr_closed?)
      .with(repo: 'gh_project_name_2', pr_id: '2')
      .and_return(true)
    expect_any_instance_of(GitHubClient).to receive(:is_pr_closed?)
      .with(repo: 'gh_project_name_2', pr_id: '3')
      .and_return(false)
    # Ensure that only the version for PR 2 is deleted
    expect_any_instance_of(BintrayClient).to receive(:delete_bintray_version)
      .with(project: 'bt_project_name_2', version: '2-abcdef')
      .and_return(true)

    gb.run(projects)
  end
end
