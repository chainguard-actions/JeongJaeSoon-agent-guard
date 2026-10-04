<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.5.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.5.6** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step of action.yml: the env var $AGENT_GUARD_PATHS, which holds the value of inputs.paths (user-controlled), is expanded **unquoted** in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker who controls the `paths` input can inject shell metacharacters (`;`, `|`, `&`, `$(...)`, glob patterns, etc.) that the shell will interpret before the command runs. The comment `# shellcheck disable=SC2086` acknowledges the unquoted expansion but does not mitigate the injection risk. The value should be passed through a safe mechanism (e.g., using an array or a null-delimited list) rather than relying on unquoted word-splitting of untrusted input.

Locations:

- `action.yml:102`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted $AGENT_GUARD_PATHS expansion in the 'Run Agent Guard' step. Replaced the unsafe `-- $AGENT_GUARD_PATHS` (which allowed shell metacharacter injection via the `paths` input) with a safe xargs-based tokenization into a bash array. The new code uses `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` piped through a NUL-delimited read loop to populate a `paths=()` array, then expands it as `"${paths[@]}"`. This preserves the whitespace-splitting behavior for multiple paths while preventing injection of `;`, `|`, `&&`, `$(...)`, glob patterns, etc. The guard `if [ -n "$AGENT_GUARD_PATHS" ]` prevents xargs from emitting a spurious empty token when the variable is empty. The `# shellcheck disable=SC2086` comment was removed as it is no longer needed.

