<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.3.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard/v1.3.4** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `AGENT_GUARD_PATHS` (sourced from `${{ inputs.paths }}`, a user-controlled input) is expanded unquoted in the run: shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The script even suppresses the shellcheck warning with `# shellcheck disable=SC2086`. An attacker can supply shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) in the `paths` input to inject arbitrary shell commands. The fix is to either properly quote the expansion or use an array to pass the paths safely.

Locations:

- `action.yml:97`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml (line 97). The unquoted `$AGENT_GUARD_PATHS` expansion was replaced with a safe bash array: `IFS=' ' read -ra paths <<< "$AGENT_GUARD_PATHS"` followed by `"${paths[@]}"`. This splits the space-separated paths into an array and expands each element with proper quoting, preventing shell metacharacter injection. The `# shellcheck disable=SC2086` suppression comment was also removed since it is no longer needed.

