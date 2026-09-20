<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.4.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.4.5** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `$AGENT_GUARD_PATHS` — which holds the value of `inputs.paths` (a caller-controlled input) — is expanded **unquoted** in the `run:` shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted shell expansion allows the shell to word-split and interpret metacharacters (`;`, `|`, `&`, `$(...)`, glob chars, etc.) present in the input value, enabling command injection. The `# shellcheck disable=SC2086` comment confirms the expansion is intentionally unquoted, but this does not mitigate the injection risk. The value should be passed safely, e.g. by reading it into an array (`read -ra paths <<< "$AGENT_GUARD_PATHS"`) and then expanding `"${paths[@]}"`.

Locations:

- `action.yml:102`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted $AGENT_GUARD_PATHS expansion in the 'Run Agent Guard' step. Replaced the unsafe `-- $AGENT_GUARD_PATHS` (with shellcheck disable comment) with a safe xargs-based array tokenization: an `if [ -n "$AGENT_GUARD_PATHS" ]` guard, a `while IFS= read -r -d '' t; do paths+=("$t"); done < <(printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0')` loop to build a bash array, and `"${paths[@]}"` expansion in the command. This prevents shell word-splitting and metacharacter injection while correctly handling the whitespace-separated paths input.

