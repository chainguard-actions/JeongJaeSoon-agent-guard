<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.5.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.5.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step of action.yml: the env var `AGENT_GUARD_PATHS` is populated from `inputs.paths` (user-controlled) and then expanded **unquoted** in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker can supply a `paths` input containing shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.) to inject arbitrary commands. The comment `# shellcheck disable=SC2086` confirms the intentional word-splitting, but this does not mitigate the injection risk. The value should be passed safely, e.g. by reading it into an array or using a null-delimited approach, rather than relying on unquoted word-splitting of untrusted input.

Locations:

- `action.yml:113`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml. The unquoted `$AGENT_GUARD_PATHS` expansion (with `# shellcheck disable=SC2086`) was replaced with a safe xargs-based array tokenization approach. The `paths` input (a whitespace-separated list) is now tokenized into a bash array using `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` with a NUL-delimited read loop, then expanded as `"${paths[@]}"`. This prevents shell metacharacter injection while preserving the intended whitespace-splitting behavior for multiple path arguments. The guard `if [ -n "$AGENT_GUARD_PATHS" ]` ensures xargs is not called with empty input.

