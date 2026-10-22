#!/usr/bin/env bash
# Usage: watch-reviews.sh <owner/repo> <pr> [<pr>...]
# Prints "COPILOT_REVIEW pr=<n> <time> status=<...> unresolved=<n>" once per PR when Copilot
# submits a review newer than its latest review request, then "ALL_REVIEWED" and exits 0.
# Portable to macOS bash 3.2 and python3 < 3.12.
set -u
repo=$1; shift
owner=${repo%%/*}; name=${repo#*/}
done_list=" "
while :; do
  for pr in "$@"; do
    case "$done_list" in *" $pr "*) continue ;; esac
    json=$(gh api graphql -F owner="$owner" -F name="$name" -F n="$pr" -f query='
      query($owner:String!,$name:String!,$n:Int!){repository(owner:$owner,name:$name){pullRequest(number:$n){
        reviewThreads(first:100){nodes{isResolved}}
        timelineItems(last:20,itemTypes:[REVIEW_REQUESTED_EVENT,PULL_REQUEST_REVIEW]){nodes{__typename
          ... on ReviewRequestedEvent{createdAt requestedReviewer{... on Bot{login}}}
          ... on PullRequestReview{createdAt author{login} body}}}}}}' 2>/dev/null) || continue
    line=$(printf '%s' "$json" | python3 -c '
import json, sys
pr = json.load(sys.stdin)["data"]["repository"]["pullRequest"]
bot = "copilot-pull-request-reviewer"
items = pr["timelineItems"]["nodes"]
reqs = [i["createdAt"] for i in items if i["__typename"] == "ReviewRequestedEvent" and (i.get("requestedReviewer") or {}).get("login") == bot]
revs = [i for i in items if i["__typename"] == "PullRequestReview" and (i.get("author") or {}).get("login") == bot]
if revs and (not reqs or revs[-1]["createdAt"] > reqs[-1]):
    body = revs[-1]["body"] or ""
    status = next((l.strip("# ").strip() for l in body.splitlines() if l.startswith("###")), "no status")
    clean = "No open issues" in body
    unresolved = sum(1 for t in pr["reviewThreads"]["nodes"] if not t["isResolved"])
    print(revs[-1]["createdAt"], "status=%r" % status, "clean=%s" % clean, "unresolved=%d" % unresolved)
')
    if [ -n "$line" ]; then
      echo "COPILOT_REVIEW pr=$pr $line"
      done_list="$done_list$pr "
    fi
  done
  left=0
  for pr in "$@"; do case "$done_list" in *" $pr "*) ;; *) left=1 ;; esac; done
  [ "$left" = 0 ] && { echo "ALL_REVIEWED"; exit 0; }
  sleep 60
done
