<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard--/v1.7.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard--/v1.7.1** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var $AGENT_GUARD_PATHS holds the value of inputs.paths (a workflow-controllable input) and is expanded unquoted in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted shell variable expansion allows an attacker-controlled value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to be interpreted by the shell, enabling command injection. The intentional shellcheck disable comment (SC2086) acknowledges the word-splitting but does not mitigate the security risk.

Locations:

- `action.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step (action.yml line 91). Replaced the unquoted `$AGENT_GUARD_PATHS` expansion (which had a `# shellcheck disable=SC2086` comment acknowledging the risk) with a safe bash array approach: `IFS=' ' read -ra paths <<< "$AGENT_GUARD_PATHS"` splits the space-separated paths safely (input is quoted, so no metacharacters are interpreted), and `"${paths[@]}"` passes each path as a separate, properly quoted argument to the agent-guard binary. This eliminates the command injection risk while preserving the intended multi-path functionality.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed hardened/action/.github/workflows/release.yml:

1. script-injection: Moved all ${{ }} expressions out of run: shell blocks into env: blocks for every affected step:
   - 'Compute next version': inputs.version → INPUT_VERSION, inputs.bump → INPUT_BUMP
   - 'Detect resume state': steps.ver.outputs.version → VER_VERSION
   - 'Bump version in tracked files': steps.ver.outputs.version → VER_VERSION
   - 'Build CHANGELOG entry': steps.ver.outputs.version → VER_VERSION
   - 'Open release PR': version/branch/previous/bump/dry_run/actor all moved to env: block
   - 'Auto-merge release PR': steps.pr.outputs.url → PR_URL
   - 'Wait for PR to merge': steps.pr.outputs.url → PR_URL
   - 'Tag and publish release': steps.ver.outputs.version → VER_VERSION, steps.ver.outputs.major → VER_MAJOR

2. github-env-injection: In 'Compute next version', sanitized all values written to $GITHUB_OUTPUT using 'printf \'%s\' "$v" | tr -d \'\n\r\'' before writing version, major, branch, and previous outputs. This prevents newline injection from the user-controlled inputs.version value.

