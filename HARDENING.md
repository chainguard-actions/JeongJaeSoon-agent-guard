<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.3.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard/v1.3.5** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step of action.yml: the env var `$AGENT_GUARD_PATHS` (sourced from `inputs.paths`, a user-controlled input) is expanded **unquoted** in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted expansion allows a caller to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) via the `paths` input, enabling arbitrary command execution. The fix is to double-quote the expansion: `-- "$AGENT_GUARD_PATHS"` (or use an array if multiple paths are needed).

Locations:

- `action.yml:92`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$AGENT_GUARD_PATHS` expansion in the 'Run Agent Guard' step of action.yml. Replaced the unquoted `-- $AGENT_GUARD_PATHS` with a bash array approach: `IFS=' ' read -ra _paths <<< "$AGENT_GUARD_PATHS"` followed by `-- "${_paths[@]}"`. This preserves the space-separated multi-path functionality while preventing shell metacharacter injection from user-controlled input.

