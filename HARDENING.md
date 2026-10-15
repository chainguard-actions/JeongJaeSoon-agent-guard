<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, `inputs.paths` is assigned to the `AGENT_GUARD_PATHS` env var via `AGENT_GUARD_PATHS: ${{ inputs.paths }}`, then expanded **unquoted** in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker who controls the `paths` input can inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to execute arbitrary commands. The comment acknowledges the unquoting is intentional for word-splitting, but this does not mitigate the injection risk. The fix is to use an array or a safer splitting mechanism that does not expose the shell to metacharacter injection.

Locations:

- `action.yml:89`
- `action.yml:97`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script-injection vulnerability in the 'Run Agent Guard' step of action.yml. The unsafe unquoted `$AGENT_GUARD_PATHS` expansion (which allowed shell metacharacter injection via the `paths` input) was replaced with a safe xargs-based array tokenization pattern. The new code uses `printf '%s' "$AGENT_GUARD_PATHS" | xargs -r printf '%s\0'` piped through a NUL-delimited read loop to populate a bash array, then expands it as `"${paths[@]}"`. This preserves the intended whitespace-splitting behavior while preventing `;`, `|`, `&`, `$(...)`, and other metacharacters from being interpreted by the shell.

