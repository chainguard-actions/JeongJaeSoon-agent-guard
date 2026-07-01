<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.5.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard/v1.5.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `AGENT_GUARD_PATHS` holds `${{ inputs.paths }}` (an attacker-controlled input) and is expanded **unquoted** in the `run:` shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The shellcheck suppression comment (`# shellcheck disable=SC2086`) confirms the unquoted expansion is intentional, but it allows an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) via the `paths` input, enabling arbitrary command execution on the runner.

Locations:

- `action.yml:92`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted expansion of $AGENT_GUARD_PATHS in the 'Run Agent Guard' step. Replaced the unquoted `$AGENT_GUARD_PATHS` expansion (which had a `# shellcheck disable=SC2086` suppression comment) with a safe bash array approach: `IFS=' ' read -ra paths_array <<< "$AGENT_GUARD_PATHS"` splits the space-separated paths into an array, and `"${paths_array[@]}"` expands each element as a separate, properly-quoted argument. This prevents shell metacharacter injection via the `paths` input while preserving the ability to pass multiple space-separated paths.

