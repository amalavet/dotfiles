#!/usr/bin/env bash
# Usage: watch-bugbot.sh <owner/repo> <pr> [<pr>...]
# Prints "BUGBOT_REVIEW pr=<n> sha=<head> result=<bucket> unresolved=<n>" once per PR when the
# "Cursor Bugbot" check on the current head commit is complete, then "ALL_REVIEWED" and exits 0.
set -u
repo=$1; shift
done_list=" "
while :; do
  for pr in "$@"; do
    case "$done_list" in *" $pr "*) continue ;; esac
    sha=$(gh pr view "$pr" -R "$repo" --json headRefOid -q .headRefOid 2>/dev/null) || continue
    bucket=$(gh api "repos/$repo/commits/$sha/check-runs?check_name=Cursor%20Bugbot" \
      -q '.check_runs[0] | if . == null then "" elif .status != "completed" then "pending" else .conclusion end' 2>/dev/null) || continue
    [ -z "$bucket" ] || [ "$bucket" = "pending" ] && continue
    unresolved=$(bash "$(dirname "$0")/unresolved.sh" "$repo" "$pr" | grep -c '^THREAD')
    echo "BUGBOT_REVIEW pr=$pr sha=${sha:0:11} result=$bucket unresolved=$unresolved"
    done_list="$done_list$pr "
  done
  left=0
  for pr in "$@"; do case "$done_list" in *" $pr "*) ;; *) left=1 ;; esac; done
  [ "$left" = 0 ] && { echo "ALL_REVIEWED"; exit 0; }
  sleep 60
done
