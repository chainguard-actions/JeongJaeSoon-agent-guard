<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.5.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.5.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: The env var `AGENT_GUARD_PATHS` is populated from `${{ inputs.paths }}` (an attacker-controlled input) and then expanded **unquoted** in the `run:` shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The script even suppresses the shellcheck warning with `# shellcheck disable=SC2086`, acknowledging the unquoted expansion. An attacker can inject shell metacharacters (`;`, `|`, `$(...)`, etc.) via the `paths` input to execute arbitrary commands on the runner. The fix is to either properly quote the expansion or use an array to pass the paths.

Locations:

- `action.yml:101`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step. The unquoted `$AGENT_GUARD_PATHS` expansion (with `# shellcheck disable=SC2086`) was replaced with a safe xargs-based array tokenization pattern. The `paths` input is a whitespace-separated list, so it's tokenized using `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` into a bash array, then expanded as `"${paths[@]}"`. This prevents shell metacharacter injection (`;`, `|`, `$(...)`, etc.) while correctly splitting the paths into separate arguments. The guard `if [ -n "$AGENT_GUARD_PATHS" ]` prevents xargs from emitting an empty token when the variable is empty.

