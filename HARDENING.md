<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.5.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.5.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `$AGENT_GUARD_PATHS` — which holds the user-controlled `${{ inputs.paths }}` input — is expanded **unquoted** inside the `run:` shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker supplying a `paths` input containing shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.) can achieve arbitrary command injection on the runner. The script even suppresses the shellcheck warning with `# shellcheck disable=SC2086`, confirming the expansion is intentionally unquoted. The fix is to use a quoted expansion or a safe word-splitting mechanism that does not allow metacharacter injection.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted $AGENT_GUARD_PATHS expansion in the 'Run Agent Guard' step. Replaced the unsafe `-- $AGENT_GUARD_PATHS` expansion (which allowed shell metacharacter injection via `;`, `|`, `&`, `$(...)`, backticks, etc.) with a safe xargs-based tokenization approach. The fix uses `printf '%s' "$AGENT_GUARD_PATHS" | xargs printf '%s\0'` piped into a `while IFS= read -r -d '' t` loop to populate a bash array, then expands it as `"${paths[@]}"`. This correctly handles the whitespace-separated paths input while preventing injection. Also removed the `# shellcheck disable=SC2086` comment that was suppressing the shellcheck warning about the unsafe expansion.

