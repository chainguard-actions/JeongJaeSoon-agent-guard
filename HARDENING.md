<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.7.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard/v1.7.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var $AGENT_GUARD_PATHS (sourced from `inputs.paths`, a user-controlled input) is expanded unquoted in the run: shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted expansion allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, etc.) from the value, enabling command injection by a caller who supplies a malicious `paths` input.

Locations:

- `action.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted $AGENT_GUARD_PATHS expansion in the 'Run Agent Guard' step (action.yml line 91). Replaced the unquoted `$AGENT_GUARD_PATHS` shell expansion (which allowed metacharacter injection) with `read -ra paths <<< "$AGENT_GUARD_PATHS"` to safely split the space-separated paths into a bash array, then passed them as `"${paths[@]}"` so each path is a separate, properly quoted argument. This prevents command injection while preserving the ability to pass multiple space-separated paths.

