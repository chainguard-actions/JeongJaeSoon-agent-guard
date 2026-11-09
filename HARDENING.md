<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.3** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step. The env var AGENT_GUARD_PATHS comes from inputs.paths and is expanded unquoted as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The shellcheck SC2086 exemption covers only an unquoted expansion inside an array assignment (NAME=($VAR)), not a bare command argument. To keep the whitespace-split behaviour, put the value in an array first (`# shellcheck disable=SC2086` followed by `paths=($AGENT_GUARD_PATHS)`), then pass "${paths[@]}".

Locations:

- `action.yml:108`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In the 'Run Agent Guard' step, the paths are now loaded with `paths=($AGENT_GUARD_PATHS)` under a SC2086 disable comment. This splits on whitespace and expands globs the same way upstream did. The array is then passed as ${paths[@]+"${paths[@]}"}, so an empty value does not fail under set -u on bash 3.2 (macOS).

