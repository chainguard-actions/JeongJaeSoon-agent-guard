<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.4.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.4.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the shell variable `$AGENT_GUARD_PATHS` — which holds the value of `inputs.paths` (an attacker-controllable input via `${{ inputs.paths }}`) — is expanded **unquoted** in the `run:` block: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker can supply a `paths` input containing shell metacharacters (e.g. `;`, `|`, `$(...)`, backticks) that will be word-split and interpreted by the shell, enabling arbitrary command execution. The `# shellcheck disable=SC2086` comment confirms the intentional unquoted expansion. The value must be double-quoted (or the paths passed via a safe mechanism such as a NUL-delimited list) to prevent injection.

Locations:

- `action.yml:106`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml (line 106). The unquoted `$AGENT_GUARD_PATHS` expansion (which held the attacker-controllable `inputs.paths` value) was replaced with a safe xargs-based tokenization approach: the whitespace-separated paths are parsed into a bash array using `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` with a NUL-delimited read loop, then the array is expanded with proper quoting (`"${paths[@]}"`). This correctly handles multiple space-separated paths while preventing shell metacharacters (`;`, `|`, `$(...)`, backticks, etc.) from being interpreted. The `# shellcheck disable=SC2086` comment was also removed as it is no longer needed.

