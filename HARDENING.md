<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) is violated: an env var holding workflow-controlled data is expanded without double quotes. The 'Run Agent Guard' step sets AGENT_GUARD_PATHS from ${{ inputs.paths }} and runs: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS` (shellcheck SC2086 is turned off). Because the expansion is unquoted, the shell splits the value on whitespace and expands glob characters from attacker-supplied input. Fix: split the value into an array safely (e.g. `read -ra paths <<< "$AGENT_GUARD_PATHS"` with globbing disabled via `set -f`) and pass "${paths[@]}".

Locations:

- `action.yml:105`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In action.yml, the 'Run Agent Guard' step no longer expands $AGENT_GUARD_PATHS unquoted. It now splits the value into an array with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true`, guarded by a non-empty check. This splits on whitespace and newlines the same way upstream did, and does no globbing or evaluation. The array is passed as ${paths[@]+"${paths[@]}"} so an empty value under set -u on bash 3.2 (macOS) doesn't fail. I also removed the shellcheck SC2086 disable. One behaviour change: glob patterns in the input are no longer expanded by the shell, so they reach the scanner as literal paths.

