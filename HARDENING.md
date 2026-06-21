<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.3.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard/v1.3.8** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, `inputs.paths` is mapped to the env var `AGENT_GUARD_PATHS` via `AGENT_GUARD_PATHS: ${{ inputs.paths }}`, but then expanded **unquoted** inside the run block: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker-controlled value for `inputs.paths` containing shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, glob chars, whitespace) would be parsed by the shell before being passed to the binary, enabling command injection. The `# shellcheck disable=SC2086` comment confirms the unquoted expansion is intentional but does not make it safe.

Locations:

- `action.yml:95`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted expansion of $AGENT_GUARD_PATHS in the 'Run Agent Guard' step. Replaced `# shellcheck disable=SC2086` + unquoted `$AGENT_GUARD_PATHS` with `IFS=' ' read -ra paths <<< "$AGENT_GUARD_PATHS"` followed by `"${paths[@]}"`. This splits the space-separated paths into a bash array so each path is passed as a separate, properly-quoted argument — shell metacharacters in attacker-controlled input are never interpreted by the shell.

