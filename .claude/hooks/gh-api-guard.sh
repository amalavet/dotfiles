#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

ask() {
  jq -n --arg reason "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:$reason}}'
  exit 0
}

if [[ "$command" =~ gh[[:space:]]+api ]] && [[ "$command" =~ (-X|--method)[=[:space:]]*[\'\"]?(POST|PUT|PATCH|DELETE) ]]; then
  ask "gh api write call (non-GET) requires manual approval"
fi

patterns=(
  'gh[[:space:]]+pr[[:space:]]+(create|close|comment|edit|lock|unlock|merge|ready|reopen|revert|review|update-branch)'
  'gh[[:space:]]+issue[[:space:]]+(create|close|comment|delete|develop|edit|lock|unlock|pin|unpin|reopen|transfer)'
  'gh[[:space:]]+repo[[:space:]]+(create|archive|delete|edit|fork|rename|sync|unarchive)'
  'gh[[:space:]]+release[[:space:]]+(create|delete|delete-asset|edit|upload)'
  'gh[[:space:]]+gist[[:space:]]+(create|delete|edit|rename)'
  'gh[[:space:]]+workflow[[:space:]]+(disable|enable|run)'
  'gh[[:space:]]+secret[[:space:]]+(set|delete)'
  'gh[[:space:]]+variable[[:space:]]+(set|delete)'
  'gh[[:space:]]+label[[:space:]]+(create|delete|edit|clone)'
  'gh[[:space:]]+project[[:space:]]+(create|close|copy|delete|edit|field-create|field-delete|item-add|item-archive|item-create|item-delete|item-edit|link|unlink)'
  'gh[[:space:]]+cache[[:space:]]+delete'
  'git[[:space:]]+push'
  'git[[:space:]]+reset[[:space:]]+--hard'
  'git[[:space:]]+clean[[:space:]]+-f'
  'git[[:space:]]+branch[[:space:]]+-D'
  'chmod[[:space:]]'
  'kubectl[[:space:]]+(apply|delete)'
  'terraform[[:space:]]+(apply|destroy)'
  'npm[[:space:]]+publish'
  'docker[[:space:]]+push'
  'rm[[:space:]]+-rf'
  'sudo[[:space:]]'
  '(curl|wget)[^|]*\|[[:space:]]*(sh|bash)'
)

for p in "${patterns[@]}"; do
  if [[ "$command" =~ $p ]]; then
    ask "command matches a gated pattern requiring manual approval: $p"
  fi
done
