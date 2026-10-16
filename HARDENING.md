<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step of action.yml: the env var `AGENT_GUARD_PATHS` is sourced from `${{ inputs.paths }}` (attacker-controlled) and then expanded **unquoted** in the run script as `$AGENT_GUARD_PATHS`. The script even suppresses the shellcheck warning with `# shellcheck disable=SC2086`. An attacker can supply a `paths` input containing shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, glob characters, etc.) that the shell will interpret when the unquoted variable expands, enabling command injection. Offending line: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`

Locations:

- `action.yml:103`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml. The unquoted `$AGENT_GUARD_PATHS` expansion (with a shellcheck disable comment) was replaced with a safe xargs-based tokenization approach: the whitespace-separated paths are split into a bash array using `printf '%s' "$AGENT_GUARD_PATHS" | xargs -r printf '%s\0'` piped through a NUL-delimited read loop, then passed to the agent-guard binary as properly quoted array elements `"${paths[@]}"`.

