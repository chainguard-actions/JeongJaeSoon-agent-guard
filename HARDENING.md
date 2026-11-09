<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.2** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): in the 'Run Agent Guard' step, the env var AGENT_GUARD_PATHS (from inputs.paths) is expanded without quotes as command arguments: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The SC2086 exemption only covers an array assignment like NAME=($VAR). This is a direct command argument, so the exemption does not apply. Suggested fix: split it into an array first with `# shellcheck disable=SC2086` followed by `paths=($AGENT_GUARD_PATHS)`, then pass "${paths[@]}".

Locations:

- `action.yml:103`

### github-env-injection (severity: high)

In the 'Install gitleaks if missing' step, `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"` writes a path built from an inherited process env var (RUNNER_TEMP). The script reads this var rather than computing it, so the check treats it as untrusted. The value is not run through `printf '%s' ... | tr -d '\n\r'` before it is written to GITHUB_PATH. Suggested fix: `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Run Agent Guard: AGENT_GUARD_PATHS is now loaded into an array with an unquoted assignment (paths=($AGENT_GUARD_PATHS), under a shellcheck SC2086 disable), then passed as ${paths[@]+"${paths[@]}"}. The paths are split on whitespace and globbed exactly as upstream did. An empty value passes no arguments, and the extra guard stops set -u from failing on an empty array under bash 3.2 (macOS). Install gitleaks: the GITHUB_PATH entry is now cleaned with printf '%s' | tr -d '\n\r' before it is written.

