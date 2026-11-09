<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.4** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) broken: an unquoted shell expansion of workflow-controlled data. In the 'Run Agent Guard' step, AGENT_GUARD_PATHS comes from ${{ inputs.paths }} and is expanded unquoted as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The '# shellcheck disable=SC2086' exemption covers only an array assignment (NAME=($VAR)), not a direct argv expansion. Fix: put the value into an array on a line with the shellcheck disable comment, e.g. `paths=($AGENT_GUARD_PATHS)`, then pass "${paths[@]}".

Locations:

- `action.yml:105`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In the 'Run Agent Guard' step, the unquoted `$AGENT_GUARD_PATHS` argument is now split into an array first (`paths=($AGENT_GUARD_PATHS)`, with the shellcheck SC2086 disable comment) and passed as `${paths[@]+"${paths[@]}"}`. Splitting and glob expansion work the same as upstream, so patterns like `cle*` still expand. The `${arr[@]+...}` form stops `set -u` from failing on an empty array under bash 3.2 (macOS). Not run or tested.

