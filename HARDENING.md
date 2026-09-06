<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.2.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): The 'Run Agent Guard' step expands `$AGENT_GUARD_PATHS` unquoted in the shell command. This env var is sourced directly from `${{ inputs.paths }}` (a caller-controlled input). The shell processes metacharacters (`;`, `|`, `$(...)`, backticks, glob chars, whitespace) in the unquoted expansion before passing arguments to the program, so an attacker can inject arbitrary shell commands via the `paths` input. The `--` separator only prevents flag injection at the program level and does not protect against shell-level metacharacter processing. Offending line: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`

Locations:

- `action.yml:113`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$AGENT_GUARD_PATHS` expansion in the 'Run Agent Guard' step (action.yml line 113). Replaced the bare `$AGENT_GUARD_PATHS` expansion with a safe xargs-based tokenization into a bash array: an `if [ -n "$AGENT_GUARD_PATHS" ]` guard prevents empty-token emission, `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` performs quote-aware tokenization without evaluating shell metacharacters, and the resulting array is expanded as `"${paths[@]}"` to keep each path as a separate, properly quoted argument to agent-guard.

