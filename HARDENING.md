<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.3.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard/v1.3.6** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var AGENT_GUARD_PATHS is populated from the attacker-controllable input `${{ inputs.paths }}` and then expanded **unquoted** in the run: block as `$AGENT_GUARD_PATHS` on the command line: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted shell variable expansion allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, whitespace splitting, glob expansion) out of the value, enabling command injection. The shellcheck disable comment (SC2086) acknowledges the unquoted expansion but does not make it safe. The fix is to either double-quote the variable (`"$AGENT_GUARD_PATHS"`) or use an array to split paths safely.

Locations:

- `action.yml:93`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$AGENT_GUARD_PATHS` expansion in the 'Run Agent Guard' step. Replaced the unquoted variable expansion (which had a `# shellcheck disable=SC2086` comment acknowledging the issue) with a safe bash array approach: `IFS=' ' read -ra paths_array <<< "$AGENT_GUARD_PATHS"` followed by `"${paths_array[@]}"`. This splits the space-separated paths into an array and expands each element as a properly quoted argument, preventing shell metacharacter injection while preserving the ability to pass multiple paths.

