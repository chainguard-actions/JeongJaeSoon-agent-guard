<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.3.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard/v1.3.7** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the shell variable `$AGENT_GUARD_PATHS` is expanded **unquoted** in the `run:` block. This variable is sourced directly from `inputs.paths` via `env: AGENT_GUARD_PATHS: ${{ inputs.paths }}`. An attacker-controlled value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, whitespace, glob chars) will be parsed by the shell before being passed to the binary, enabling command injection. The offending line is: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The comment `# shellcheck disable=SC2086` explicitly suppresses the shellcheck warning about this unquoted expansion, but disabling the lint check does not eliminate the security risk. Fix: use `"$AGENT_GUARD_PATHS"` (quoted) or, if word-splitting on spaces is intentional, use an array: `read -ra paths <<< "$AGENT_GUARD_PATHS"` and then `... -- "${paths[@]}"`.

Locations:

- `action.yml:96`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$AGENT_GUARD_PATHS` expansion in the 'Run Agent Guard' step. Replaced the unquoted `$AGENT_GUARD_PATHS` (with `# shellcheck disable=SC2086` suppression) with a safe bash array: `read -ra paths <<< "$AGENT_GUARD_PATHS"` followed by `"${paths[@]}"`. This preserves the intentional word-splitting on spaces for the space-separated paths input while preventing shell metacharacter injection, since each array element is properly double-quoted when expanded.

