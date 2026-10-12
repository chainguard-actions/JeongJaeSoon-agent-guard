<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.1** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step: the env var $AGENT_GUARD_PATHS, which holds the user-controlled input `${{ inputs.paths }}`, is expanded **unquoted** in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker can supply a `paths` input containing shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.) to inject arbitrary shell commands. The `# shellcheck disable=SC2086` comment confirms the intentional unquoted word-splitting, but this does not mitigate the injection risk. The value must be double-quoted (`"$AGENT_GUARD_PATHS"`) or the multi-path splitting must be handled via a safe array mechanism.

Locations:

- `action.yml:87`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml. The unquoted `$AGENT_GUARD_PATHS` expansion was replaced with a safe xargs-based tokenization into a bash array. The paths input is whitespace-separated, so we use `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` to tokenize it with proper quote-awareness, read the NUL-delimited tokens into a `paths=()` array, and then expand it as `"${paths[@]}"`. A guard `if [ -n "$AGENT_GUARD_PATHS" ]` prevents xargs from emitting an empty argument when the variable is empty. The `# shellcheck disable=SC2086` comment was removed as it is no longer needed.

