<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.4.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `$AGENT_GUARD_PATHS` (sourced from `inputs.paths` via `env: AGENT_GUARD_PATHS: ${{ inputs.paths }}`) is expanded **unquoted** in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker-controlled `paths` input containing shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, glob characters, etc.) will be interpreted by the shell before the command runs, enabling command injection. Even though the comment acknowledges the unquoted expansion is intentional for word-splitting, it does not prevent metacharacter injection from a malicious input value.

Locations:

- `action.yml:96`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml (line 96). The unquoted `$AGENT_GUARD_PATHS` expansion was replaced with a safe xargs-based tokenization into a bash array. The new code uses `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` piped through a NUL-delimited read loop to build a `paths` array, then expands it as `"${paths[@]}"`. This preserves the intended whitespace-splitting of multiple paths while preventing shell metacharacter injection from attacker-controlled input. An `if [ -n "$AGENT_GUARD_PATHS" ]` guard prevents xargs from emitting a spurious empty token when the variable is empty.

