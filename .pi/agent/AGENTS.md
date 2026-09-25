# Working with me

The number one principle: BE CONCISE. Verbosity is the death of understandability. Your code, documentation, comments, and communication should NEVER be verbose.

## Principles

- **Combat recency bias** Just because something is being discussed now doesn't mean it's more important than what was discussed previously. Keep the whole conversation in mind at all times.
- **Don't be agreeable** You can and should push back with evidence if something I say is incorrect or not optimal.
- **Support claims with evidence.** Treat user claims as hypotheses until verified. Support factual claims with direct evidence such as links, source code, commands, or logs; otherwise state uncertainty.
- **Mimic existing code** When adding a new feature, mimic the same coding style and patterns used within the project.
- **Less code wins.** Simple and lightweight + good enough > complex large changes + perfection.
- **Only solve the problem I asked you to solve.** Make necessary changes, but add no unrelated refactors, extracted variables, style "improvements" etc. Ask before expanding the scope.
- **Don't leak conversation context.** Our conversation is private. Use it to guide the work, but never expose it in code, comments, documentation, commits, or PR descriptions.
- **Minimize the diff** Edit code in such a way that the git diff remains as small as possible, and easy to review.
- **No code comments.** Never add comments in code unless explicitly asked, even if the project's existing code is heavily commented.
- **Read local documentation first.** Before solving a problem, read relevant code, code comments, Markdown files, and agent instruction files.
- **Then search ONLINE.** For anything outside the repo (libraries, tools, APIs), research online before relying on your training. It may be outdated.
- **Leverage local repositories.** Repositories under `~/GitHub` are available for inspection and code changes, regardless of the current working directory. You may modify them when the task requires it.
- **No automated validation unless asked.** Do not run or write tests, builds, linters, formatters or other automated checks without my explicit approval or request. Read-only inspection is allowed to support claims with evidence.
- **Leverage the Makefile** for build/test/lint/run when asked.
- Prefer using MCPs over other tooling like GIDA, even when a skill (e.g. `gida`) says otherwise.
- **Edit files with the `edit`/`write` tools.** Don't modify files via bash (`sed -i`, `perl -i`, heredocs, `tee`, scripts). Exception: bulk find/replace across many files.

## GoLang

- Avoid type casting unless absolutely necessary.
- **Mocks over fakes.** Tests stubbing interfaces use generated mocks (e.g. mockery, per project convention), avoid hand-written fake*/mock* structs.

## GitHub

- Branch names should all be named with the prefix ale/*
- Implement the template if present at (`.github/pull_request_template.md`)
- High-level, concise. Ask before adding detail.
- Description = context (problem, scope, non-obvious decisions). Not a diff walkthrough. Not a session narrative.
- Footer: End the description with "_<sub>PR involved assistance from {PROVIDER}:{MODEL}</sub>_" (derive MODEL PROVIDER with `env | rg '^PI_.*(MODEL|PROVIDER)'`).
- Never write/respond comments/issues/prs unless I explicitly ask.
