<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.5** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

The 'Install gitleaks if missing' step writes a value built from the inherited process env var RUNNER_TEMP to $GITHUB_PATH without the required sanitization: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. RUNNER_TEMP is read, not set, inside this composite run script, so under rule (e) it counts as caller-controlled. Fix: `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:96`

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step. The env var AGENT_GUARD_PATHS comes from inputs.paths and is expanded without quotes: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The shell applies word splitting and glob expansion to the input value. The code needs whitespace splitting, so split safely with `read -ra paths <<< "$AGENT_GUARD_PATHS"` and pass `"${paths[@]}"` instead (and turn off globbing with `set -f` if needed).

Locations:

- `action.yml:110`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection

**Notes:**

github-env-injection: the RUNNER_TEMP-derived path now goes through tr -d '\n\r' before it is written to $GITHUB_PATH. script-injection: the unquoted $AGENT_GUARD_PATHS is replaced with a whitespace/newline split into an array (read -r -d '' -a ... || true, behind a non-empty check). The array is expanded with ${paths[@]+"${paths[@]}"} so an empty value doesn't trip set -u on bash 3.2 (macOS). Upstream splitting behaviour is kept. The one change: paths are no longer glob-expanded.

