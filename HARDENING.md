<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.5.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.5.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `AGENT_GUARD_PATHS` is populated from `inputs.paths` (attacker-controlled) and then expanded **unquoted** in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker-supplied `inputs.paths` value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, glob patterns) will be interpreted by the shell before being passed to the binary, enabling command injection. The `# shellcheck disable=SC2086` comment confirms the intentional unquoted expansion, but this does not mitigate the injection risk. The value must be quoted or the input must be sanitized before use.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml. The unquoted `$AGENT_GUARD_PATHS` expansion (with `# shellcheck disable=SC2086`) was replaced with a safe xargs-based tokenization approach. The whitespace-separated paths input is now split into a bash array using `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` with a `while IFS= read -r -d '' t` loop, guarded by `if [ -n "$AGENT_GUARD_PATHS" ]` to prevent xargs from running on empty input. The array is then expanded as `"${paths[@]}"` so each path is a separate, properly quoted argument — shell metacharacters in the input are never interpreted by the shell.

