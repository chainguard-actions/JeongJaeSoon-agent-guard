<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.1.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.1.0** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `$AGENT_GUARD_PATHS` holds the value of `inputs.paths` (user-controlled) and is expanded **unquoted** in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker can supply a value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to inject arbitrary commands. The `# shellcheck disable=SC2086` comment confirms the unquoted expansion is intentional but does not mitigate the injection risk.

Locations:

- `action.yml:95`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml (line 95). The unquoted `$AGENT_GUARD_PATHS` expansion (which allowed shell metacharacter injection via the `paths` input) was replaced with a safe xargs-based tokenization into a bash array. The `paths` input is a whitespace-separated list, so it is tokenized with `xargs printf '%s\0'` into a NUL-delimited stream read by a `while IFS= read -r -d '' t` loop into a `paths=()` array. The array is then expanded as `"${paths[@]}"` so each path is a separate, properly-quoted argument. An `if [ -n "$AGENT_GUARD_PATHS" ]` guard prevents xargs from emitting a spurious empty token when the variable is empty. The `# shellcheck disable=SC2086` comment was removed as it is no longer needed.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all 14 script injection locations in .github/workflows/release.yml by moving every ${{ }} expression out of run: shell strings and into the step's env: block. Each expression is now referenced as a plain shell variable ($VAR_NAME) in the run: script. Steps affected: 'Compute next version' (INPUT_BUMP), 'Detect resume state' (VER_VERSION), 'Bump version in tracked files' (VER_VERSION), 'Build CHANGELOG entry' (VER_VERSION), 'Open release PR' (VER_VERSION, VER_BRANCH, VER_PREVIOUS, GITHUB_ACTOR_NAME, INPUT_BUMP, INPUT_DRY_RUN), 'Auto-merge release PR' (PR_URL), 'Wait for PR to merge' (PR_URL), 'Tag and publish release' (VER_VERSION, VER_MAJOR).

