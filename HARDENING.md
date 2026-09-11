<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.3.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.3.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): In the 'Run Agent Guard' step, the env var `$AGENT_GUARD_PATHS` (sourced from `inputs.paths`, an attacker-controllable input) is expanded **unquoted** inside the `run:` shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted shell expansion allows an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, whitespace word-splitting, glob expansion, etc.) via the `paths` input. The `# shellcheck disable=SC2086` comment confirms the expansion is intentional but does not mitigate the injection risk. The fix is to use a properly quoted form or an array-based expansion.

Locations:

- `action.yml:98`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$AGENT_GUARD_PATHS` expansion in the 'Run Agent Guard' step. Replaced the unquoted `$AGENT_GUARD_PATHS` (with `# shellcheck disable=SC2086`) with a safe xargs-based tokenization into a bash array. The fix uses `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` piped through a `while IFS= read -r -d '' t` loop to populate a `paths` array, then expands it as `"${paths[@]}"`. This prevents shell metacharacter injection (`;`, `|`, `&`, `$(...)`, glob expansion, etc.) while correctly handling the whitespace-separated paths input. The `if [ -n "$AGENT_GUARD_PATHS" ]` guard prevents xargs from emitting an empty token when the variable is empty.

