<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.4.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.4.2** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step: the env var AGENT_GUARD_PATHS is sourced from the user-controlled input `${{ inputs.paths }}` and then expanded **unquoted** in the run block as `$AGENT_GUARD_PATHS`. The shellcheck suppression comment (`# shellcheck disable=SC2086`) confirms the unquoted expansion is intentional for word-splitting, but it also allows an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.) via the `paths` input. The offending line is: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`

Locations:

- `action.yml:97`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml. The original code expanded `$AGENT_GUARD_PATHS` unquoted (with a shellcheck suppression comment), allowing shell metacharacters in the `paths` input to be interpreted as shell syntax. The fix uses xargs-based tokenization to safely split the whitespace-separated paths into a bash array (`paths=()`), then expands it as `"${paths[@]}"`. This preserves the intended word-splitting behavior while preventing injection of shell metacharacters like `;`, `|`, `&`, `$(...)`, and backticks.

