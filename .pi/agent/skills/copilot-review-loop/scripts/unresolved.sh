#!/usr/bin/env bash
# Usage: unresolved.sh <owner/repo> <pr>
# Prints each unresolved review thread: thread ID, first comment ID, path:line, then all comments.
set -eu
repo=$1; pr=$2
gh api graphql -F owner="${repo%%/*}" -F name="${repo#*/}" -F n="$pr" -f query='
  query($owner:String!,$name:String!,$n:Int!){repository(owner:$owner,name:$name){pullRequest(number:$n){
    reviewThreads(first:100){nodes{id isResolved isOutdated path line
      comments(first:20){nodes{databaseId author{login} createdAt body}}}}}}}' \
  --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved | not) |
    "THREAD \(.id) comment=\(.comments.nodes[0].databaseId) \(.path):\(.line) outdated=\(.isOutdated)\n" +
    ([.comments.nodes[] | "  \(.author.login) \(.createdAt): \(.body)"] | join("\n")) + "\n"'
