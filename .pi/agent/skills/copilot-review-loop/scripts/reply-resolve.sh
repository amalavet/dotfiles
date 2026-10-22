#!/usr/bin/env bash
# Usage: reply-resolve.sh <owner/repo> <pr> <comment-id> <thread-id> <body-or-@file>
# Replies in the thread (a commit SHA, or @file with the reasoning), then resolves the thread.
set -eu
repo=$1; pr=$2; comment=$3; thread=$4; body=$5
if [ "${body#@}" != "$body" ]; then
  gh api -X POST "repos/$repo/pulls/$pr/comments/$comment/replies" -F body="$body" --jq .html_url
else
  gh api -X POST "repos/$repo/pulls/$pr/comments/$comment/replies" -f body="$body" --jq .html_url
fi
gh api graphql -f id="$thread" -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' \
  --jq '"resolved=\(.data.resolveReviewThread.thread.isResolved)"'
