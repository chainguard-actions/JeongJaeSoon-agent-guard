<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.5.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.5.5** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `AGENT_GUARD_PATHS` is populated from `inputs.paths` (user-controlled) and then expanded **unquoted** in the run block: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker can supply a value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to inject arbitrary shell commands. The `# shellcheck disable=SC2086` comment acknowledges the unquoted expansion but does not mitigate the injection risk. The fix is to either double-quote the expansion (`"$AGENT_GUARD_PATHS"`) or use an array to safely split the paths.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml. Replaced the unquoted `$AGENT_GUARD_PATHS` expansion (with `# shellcheck disable=SC2086` comment acknowledging the risk) with a safe xargs-based array tokenization pattern. The fix uses `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` piped through a NUL-delimited read loop to populate a bash array, then expands it as `"${paths[@]}"`. This correctly handles multiple whitespace-separated paths while preventing shell metacharacter injection. An `if [ -n "$AGENT_GUARD_PATHS" ]` guard prevents xargs from emitting a spurious empty argument when the variable is empty.

