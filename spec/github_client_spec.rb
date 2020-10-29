require 'github_client'
require 'json'
require 'net/http'

RSpec.describe GitHubClient do

  let(:base_url) { 'https://test.com' }

  describe 'checking if a PR in a repo is closed' do

    let(:repo) { 'a-repo' }
    let(:pr) { 123 }

    context 'when the request is successful' do

      it 'returns true if the state is closed' do
        stub_request(:get, "#{base_url}/repos/#{repo}/pulls/#{pr}")
          .to_return(status: 200, body: get_pr_response('closed'))

        client = GitHubClient.new(base_url)
        result = client.is_pr_closed?(repo, pr)

        expect(result).to be_truthy
      end

      it 'returns false if the state is not closed' do
        stub_request(:get, "#{base_url}/repos/#{repo}/pulls/#{pr}")
          .to_return(status: 200, body: get_pr_response('open'))

        client = GitHubClient.new(base_url)
        result = client.is_pr_closed?(repo, pr)

        expect(result).to be_falsy
      end
    end

    context 'when the response has not state key' do

      it 'returns false' do
        stub_request(:get, "#{base_url}/repos/#{repo}/pulls/#{pr}")
          .to_return(status: 200, body: { foo: 'bar' }.to_json)

        client = GitHubClient.new(base_url)
        result = client.is_pr_closed?(repo, pr)

        expect(result).to be_falsy
      end
    end

    context 'when the request fails' do

      it 'returns false' do
        stub_request(:get, "#{base_url}/repos/#{repo}/pulls/#{pr}")
          .to_return(status: 400)

        client = GitHubClient.new(base_url)
        result = client.is_pr_closed?(repo, pr)

        expect(result).to be_falsy
      end
    end
  end

  it 'can initialize without an explicit base_url value' do
    client = GitHubClient.new
    expect(client).to_not be_nil
  end
end

def get_pr_response(state)
  # This is only a fragment of the full API response with the data relevant the
  # job we have to do.
  #
  # See https://docs.github.com/en/free-pro-team@latest/rest/reference/pulls#get-a-pull-request
  %Q{
{
  "url": "https://api.github.com/repos/octocat/Hello-World/pulls/1347",
  "id": 1,
  "node_id": "MDExOlB1bGxSZXF1ZXN0MQ==",
  "html_url": "https://github.com/octocat/Hello-World/pull/1347",
  "diff_url": "https://github.com/octocat/Hello-World/pull/1347.diff",
  "patch_url": "https://github.com/octocat/Hello-World/pull/1347.patch",
  "issue_url": "https://api.github.com/repos/octocat/Hello-World/issues/1347",
  "commits_url": "https://api.github.com/repos/octocat/Hello-World/pulls/1347/commits",
  "review_comments_url": "https://api.github.com/repos/octocat/Hello-World/pulls/1347/comments",
  "review_comment_url": "https://api.github.com/repos/octocat/Hello-World/pulls/comments{/number}",
  "comments_url": "https://api.github.com/repos/octocat/Hello-World/issues/1347/comments",
  "statuses_url": "https://api.github.com/repos/octocat/Hello-World/statuses/6dcb09b5b57875f334f61aebed695e2e4193db5e",
  "number": 1347,
  "state": "#{state}",
  "locked": true,
  "title": "Amazing new feature",
  "user": {},
  "body": "Please pull these awesome changes in!",
  "labels": [],
  "milestone": {},
  "active_lock_reason": "too heated",
  "created_at": "2011-01-26T19:01:12Z",
  "updated_at": "2011-01-26T19:01:12Z",
  "closed_at": "2011-01-26T19:01:12Z",
  "merged_at": "2011-01-26T19:01:12Z",
  "merge_commit_sha": "e5bd3914e2e596debea16f433f57875b5b90bcd6",
  "assignee": {},
  "assignees": [],
  "requested_reviewers": [],
  "requested_teams": [],
  "head": {},
  "base": {},
  "_links": {},
  "author_association": "OWNER",
  "draft": false,
  "merged": false,
  "mergeable": true,
  "rebaseable": true,
  "mergeable_state": "clean",
  "merged_by": {},
  "comments": 10,
  "review_comments": 0,
  "maintainer_can_modify": true,
  "commits": 3,
  "additions": 100,
  "deletions": 3,
  "changed_files": 5
}
  }
end
