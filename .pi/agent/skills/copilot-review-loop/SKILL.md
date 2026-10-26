---
name: copilot-review-loop
description: Run a Copilot code review loop on one or more GitHub PRs until every PR has a clean Copilot review. Covers requesting Copilot, watching for reviews with the process tool, triaging each comment against the code, fixing and testing real issues, replying and resolving threads, and keeping PR descriptions accurate. Use when asked to "loop on Copilot reviews", "address Copilot comments until green", or "re-request Copilot and fix what it finds".
---

# Copilot review loop

Scripts are in `scripts/` next to this file. They work with macOS bash 3.2 and python3 before 3.12.

## Setup (once)

1. Make one worktree per PR. The local branch name and its upstream must be the PR head branch, so `git push --force-with-lease` works with no arguments:
   ```bash
   git worktree add /tmp/wt-<pr> <head-branch>   # or: git worktree add -b <head-branch> /tmp/wt-<pr> origin/<head-branch>
   git -C /tmp/wt-<pr> branch -u origin/<head-branch>
   git -C /tmp/wt-<pr> status -sb                # must show "## <head-branch>...origin/<head-branch>"
   ```
2. Write down the context that the PRs can assume, for example a sibling patch that always ships with them. Comments about problems that this context already solves are out of scope. Get this from the user if it is not clear.
3. Find the test commands for the changed code, and the bases that each PR must work on (base branch, and any patched variants). Keep one test worktree per base, separate from the PR worktrees.

## One round

1. **Request Copilot** on each PR that is not clean:
   ```bash
   gh pr edit <pr> -R <owner/repo> --add-reviewer @copilot
   ```
   The CLI and API cannot select a review mode such as "balanced". If the user needs a mode, tell them to select it in the GitHub UI.
   Cursor Bugbot reviews each push without a request. Its status is the `Cursor Bugbot` check on the head commit. To run it again with no push, comment `bugbot run` on the PR.
2. **Watch** with the process tool. Do not sleep or poll in the turn:
   ```json
   {"action":"start","name":"copilot-watch-round-<n>","command":"sleep 30; bash <skill>/scripts/watch-reviews.sh <owner/repo> <pr> <pr>",
    "notify":{"onSuccess":"turn","onFailure":"turn","logMatches":[
      {"pattern":"COPILOT_REVIEW","repeat":true,"on":"context"},
      {"pattern":"Error|Traceback|invalid option","mode":"regex","on":"turn"}]}}
   ```
   The script exits after each PR has a Copilot review newer than its last request. Check its stderr once after start: a script error must not look like "no review yet".
   Start a second process with `scripts/watch-bugbot.sh <owner/repo> <pr> <pr>` and the pattern `BUGBOT_REVIEW`. It exits when the `Cursor Bugbot` check on each PR head is complete.
   Triage the Copilot and the Bugbot threads the same way.
3. **List the open threads** on each PR:
   ```bash
   bash <skill>/scripts/unresolved.sh <owner/repo> <pr>
   ```
4. **Triage each comment** against the code at the PR head. For each one, decide:
   - **Real issue:** a code path, with `file:line`, that shows the problem in the context that ships. Fix it.
   - **Not an issue:** find the evidence: the code that prevents it, a test that covers it, or the assumed context from setup step 2. Reply with that evidence.
   - **Out of scope:** a different vulnerability or a pre-existing issue. Reply with the reason and a link to where it is handled.
   Check that a fix does not reverse an earlier fix. Read the earlier threads on the same lines first.
5. **Fix real issues** in each PR that has the same code:
   - Make the smallest change. Follow the repo rules for the PR type (for example, security patches: no refactors).
   - Add a test that fails without the fix. Run it once with the old code to prove that it fails, then with the fix.
   - Run `go build`, `go vet` and `gofmt -l` (or the repo equivalents) on each worktree.
   - Amend or commit, then push: `git push --force-with-lease`.
6. **Reply and resolve** each thread:
   ```bash
   bash <skill>/scripts/reply-resolve.sh <owner/repo> <pr> <comment-id> <thread-id> <full-commit-sha>   # fixed
   bash <skill>/scripts/reply-resolve.sh <owner/repo> <pr> <comment-id> <thread-id> @/tmp/reply.md     # not fixed: evidence
   ```
   Only state test results in a reply after the test ran on that commit.
7. **Update the PR descriptions** after each push:
   - Links to code must point at the new head SHA. Recompute the line numbers from the worktree, then check that each linked line contains the linked name.
   - Remove statements that the new code makes false. Add the new tests.
8. **Run the full tests** in the background with the process tool, on each base. Reset each test worktree to its base before you apply the new patch, and remove untracked files that the patch adds. Before you start a new run, stop the old one and clean its worktrees (`git am --abort`, reset).
9. Go to step 1.

## Stop condition

Stop when, for each PR, the latest Copilot review is newer than the last request, the body contains "No open issues", the `Cursor Bugbot` check on the head commit is complete, and `unresolved.sh` prints nothing. A status such as "Needs a closer look" with "No open issues" is clean.

## Report each round

- Per PR: the Copilot status, each comment, the verdict (fixed, not an issue, out of scope) with evidence, and links to the reply and the commit.
- What is tested and what is not tested yet.
- The running processes and what each one waits for.
