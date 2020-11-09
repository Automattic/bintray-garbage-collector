def get_pr_response(state)
  # This is only a fragment of the full API response with the data relevant to
  # the job we have to do.
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
