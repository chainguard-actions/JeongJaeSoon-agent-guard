<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.1.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.1.1** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `$AGENT_GUARD_PATHS` — which holds the value of `inputs.paths` (a workflow-controllable input) — is expanded unquoted inside the run: script: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted shell expansion allows an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, glob chars) via the `paths` input, enabling command injection. The comment acknowledges the unquoting is intentional for word-splitting, but this does not prevent metacharacter injection. The safe alternative is to use an array or a newline-delimited read loop rather than bare word-splitting.

Locations:

- `action.yml:103`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml. Replaced the unquoted `$AGENT_GUARD_PATHS` expansion (which allowed shell metacharacter injection via the `paths` input) with a safe xargs-based array tokenization pattern. The fix uses `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` piped into a `while IFS= read -r -d '' t` loop to populate a bash array, then passes `"${paths[@]}"` to the agent-guard command. This correctly splits whitespace-separated paths while preventing injection of shell metacharacters. The `if [ -n "$AGENT_GUARD_PATHS" ]` guard prevents xargs from emitting an empty token when the input is empty.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script injection and github-env-injection issues in .github/workflows/release.yml:

1. **script-injection**: Moved all ${{ }} expressions from run: shell scripts into env: blocks:
   - 'Compute next version': Added INPUT_BUMP env var; replaced `case "${{ inputs.bump }}"` with `case "$INPUT_BUMP"`
   - 'Detect resume state': Added VER_VERSION env var; replaced inline version interpolation
   - 'Bump version in tracked files': Added VER_VERSION env var
   - 'Build CHANGELOG entry': Added VER_VERSION env var
   - 'Open release PR': Added VER_VERSION, VER_BRANCH, GITHUB_ACTOR, VER_PREVIOUS, INPUT_BUMP, INPUT_DRY_RUN env vars; replaced all inline ${{ }} in printf arguments
   - 'Auto-merge release PR': Added PR_URL env var; replaced `gh pr merge "${{ steps.pr.outputs.url }}"`
   - 'Wait for PR to merge': Added PR_URL env var; replaced `gh pr view "${{ steps.pr.outputs.url }}"`
   - 'Tag and publish release': Added VER_VERSION and VER_MAJOR env vars

2. **github-env-injection**: Added sanitization in 'Compute next version' step before writing to $GITHUB_OUTPUT. Values derived from inputs are now sanitized with `printf '%s' "$var" | tr -d '\n\r'` before being written to GITHUB_OUTPUT, preventing newline injection attacks.

