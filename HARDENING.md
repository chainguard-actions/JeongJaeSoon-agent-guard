<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: In the 'Run Agent Guard' step, the env var `AGENT_GUARD_PATHS` is sourced from `${{ inputs.paths }}` (an attacker-controlled input) and then expanded **unquoted** in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted shell expansion allows the shell to interpret metacharacters (`;`, `|`, `&`, `$(...)`, backticks, glob chars) embedded in the input value, enabling command injection. The `# shellcheck disable=SC2086` comment confirms the author is aware of the word-splitting but the security risk remains. The guarded-form exception (`${VAR:+"$VAR"}`) does not apply here because this is not a single optional positional argument — it is intentional multi-word splitting of a user-controlled string.

Locations:

- `action.yml:101`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script-injection vulnerability in the 'Run Agent Guard' step of action.yml. The unquoted `$AGENT_GUARD_PATHS` expansion (which allowed shell metacharacter injection via the `inputs.paths` value) was replaced with a safe xargs-based tokenization pattern. The fix uses `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` piped into a `while IFS= read -r -d '' t; do paths+=("$t"); done` loop to safely split the whitespace-separated paths list into a bash array, guarded by `if [ -n "$AGENT_GUARD_PATHS" ]` to prevent xargs from emitting an empty token when the variable is empty. The array is then expanded as `"${paths[@]}"` to pass each path as a separate, properly-quoted argument to agent-guard. The `# shellcheck disable=SC2086` comment was removed as it is no longer needed.

