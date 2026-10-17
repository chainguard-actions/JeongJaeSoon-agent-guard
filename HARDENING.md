<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.4** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation in the 'Run Agent Guard' step of action.yml: the env var AGENT_GUARD_PATHS is sourced from inputs.paths (attacker-controlled) and is expanded unquoted in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The intentional word-splitting (noted by `# shellcheck disable=SC2086`) also allows shell metacharacter injection (`;`, `|`, `&`, `$(...)`, backticks, glob chars) from the inputs.paths value. The variable must be double-quoted or the input must be sanitized before use.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed script injection in the 'Run Agent Guard' step of action.yml (line 100). The unquoted `$AGENT_GUARD_PATHS` expansion (with `# shellcheck disable=SC2086`) allowed shell metacharacter injection from the attacker-controlled `inputs.paths` value. Replaced with a safe xargs-based tokenization pattern: the whitespace-separated paths are tokenized into a bash array using `printf '%s' "$AGENT_GUARD_PATHS" | xargs -r printf '%s\0'` with a null-delimited read loop, then the array is expanded as `"${paths[@]}"`. This preserves the intended word-splitting behavior for legitimate whitespace-separated paths while preventing injection of `;`, `|`, `&`, `$(...)`, backticks, and glob characters. An `if [ -n "$AGENT_GUARD_PATHS" ]` guard prevents xargs from emitting an empty token on empty input.

