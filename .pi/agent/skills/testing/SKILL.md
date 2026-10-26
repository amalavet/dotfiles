---
name: testing
description: How the user wants tests structured. Use when writing, moving, or reviewing tests, test suites, helpers, fixtures, or mocks.
---

# testing

## Test forward

A reader opens a test file to read the tests. Make the tests the first and main thing they see.

- A suite file contains only the suite entry point and the test cases. No helpers, fixtures, or mocks.
- Put helpers, fixtures, and mocks in their own files (for example `helpers.go`, `provider.go`, `mock.go`, `<provider>_mock_test.go`, `main_test.go`).
- A test file holds tests first. A reader who wants to know how a helper works goes to its file.
- The reader must not scroll through setup code to reach the tests.

## Shared helpers

- If two places use the same helper, move it to the shared package (for example `common`). Do not keep two copies.
- Before you write a helper, look for one in the shared package. Use it, even if its signature is a little different.

## Shared suites

- A shared suite runs only the cases that exercise provider-specific code. Provider-agnostic behavior gets its own tests that run once.
- Each provider file calls the suite itself. No extra caller file.
- Keep the provider fixture minimal: the smallest interface or struct that injects a provider into the suite.
- Structure parallel repositories (for example OSS and enterprise) the same way.
