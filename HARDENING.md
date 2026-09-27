<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.5.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.5.4** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: The env var `$AGENT_GUARD_PATHS` holds a value sourced from `inputs.paths` (an attacker-controllable input) and is expanded **unquoted** inside the `run:` shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted expansion allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, backticks, glob chars, whitespace word-splitting) out of the value, enabling command injection. The comment `# shellcheck disable=SC2086` and the stated intent of word-splitting on whitespace do not mitigate the injection risk from shell metacharacters embedded in the input. The value must be double-quoted or the input must be sanitized before use.

Locations:

- `action.yml:107`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$AGENT_GUARD_PATHS` expansion in action.yml line 107. Replaced `-- $AGENT_GUARD_PATHS` (unquoted, injection-vulnerable) with a safe xargs-based tokenization pattern: paths are split into a bash array using `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` piped through a null-delimited read loop, then expanded as `"${paths[@]}"`. This preserves the intended whitespace-splitting behavior while preventing injection of shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, globs). The `if [ -n "$AGENT_GUARD_PATHS" ]` guard prevents xargs from emitting an empty argument when the input is empty.

