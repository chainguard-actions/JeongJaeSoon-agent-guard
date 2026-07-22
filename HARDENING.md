<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.10.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.10.1** was hardened automatically. 1 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: The env var `$AGENT_GUARD_PATHS` — which holds the value of `inputs.paths` (user-controlled) — is expanded **unquoted** in the shell command on the last line of the "Run Agent Guard" step: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted expansion allows shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, glob characters, etc.) embedded in the `inputs.paths` value to be interpreted by the shell, enabling command injection. The `# shellcheck disable=SC2086` comment acknowledges the lack of quoting but does not mitigate the security risk. The fix is to either quote the variable (`"$AGENT_GUARD_PATHS"`) or use an array to handle multiple paths safely.

Locations:

- `action.yml:99`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$AGENT_GUARD_PATHS` expansion in the 'Run Agent Guard' step of action.yml. Replaced the unquoted `$AGENT_GUARD_PATHS` variable expansion (which allowed shell metacharacters to be interpreted) with a safe bash array approach: `IFS=' ' read -ra paths_array <<< "$AGENT_GUARD_PATHS"` splits the space-separated paths into array elements without shell interpretation, and `"${paths_array[@]}"` passes each path as a properly quoted argument. The `# shellcheck disable=SC2086` comment acknowledging the unsafe expansion was also removed.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all 8 script-injection findings in hardened/action/.github/workflows/release.yml by moving every ${{ }} expression out of run: shell script blocks and into the step's env: block. Each expression is now referenced as a plain environment variable in the shell script:
- 'Compute next version': inputs.version → INPUT_VERSION, inputs.bump → INPUT_BUMP
- 'Detect resume state': steps.ver.outputs.version → VER_VERSION
- 'Bump version in tracked files': steps.ver.outputs.version → VER_VERSION
- 'Build CHANGELOG entry': steps.ver.outputs.version → VER_VERSION
- 'Open release PR': steps.ver.outputs.version → VER_VERSION, steps.ver.outputs.branch → VER_BRANCH, github.actor → GITHUB_ACTOR_NAME, steps.ver.outputs.previous → VER_PREVIOUS, inputs.bump → INPUT_BUMP, inputs.dry_run → INPUT_DRY_RUN
- 'Auto-merge release PR': steps.pr.outputs.url → PR_URL
- 'Wait for PR to merge': steps.pr.outputs.url → PR_URL
- 'Tag and publish release': steps.ver.outputs.version → VER_VERSION, steps.ver.outputs.major → VER_MAJOR
All remaining ${{ }} expressions are only in env: values and if: conditions, which are safe.

### Iteration 3

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in .github/workflows/release.yml at the 'Compute next version' step. Added sanitization using `tr -d '\n\r'` for all three variables written to $GITHUB_OUTPUT: `safe_v` (from `$v`), `safe_MA` (from `$MA`), and `safe_cur` (from `$cur`). All four GITHUB_OUTPUT writes (version, major, branch, previous) now use the sanitized variables, preventing newline injection attacks where an embedded newline in the `inputs.version` value could bypass the line-anchored regex validation and inject additional key=value pairs into GITHUB_OUTPUT.

