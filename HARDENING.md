<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.4.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.4.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: The env var `AGENT_GUARD_PATHS` holds the value of `${{ inputs.paths }}` (a user-controlled input) and is expanded **unquoted** in the `run:` shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker can supply a `paths` input containing shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.) to inject arbitrary shell commands. The `# shellcheck disable=SC2086` comment acknowledges the word-splitting is intentional, but it does not mitigate the injection risk from attacker-controlled values.

Locations:

- `action.yml:113`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted expansion of `$AGENT_GUARD_PATHS` in the 'Run Agent Guard' step. The paths input is a whitespace-separated list, so the fix uses xargs to safely tokenize it into a bash array (`paths=()`), guarded by `if [ -n "$AGENT_GUARD_PATHS" ]` to avoid an empty token when the variable is empty. The array is then expanded as `"${paths[@]}"` so each path is a separate, properly-quoted argument. Shell metacharacters in the input are passed as literal text by xargs rather than being interpreted by the shell, eliminating the injection risk.

