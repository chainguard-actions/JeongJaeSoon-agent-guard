<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.7** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation in the 'Run Agent Guard' step. The env var AGENT_GUARD_PATHS comes from ${{ inputs.paths }} and is expanded without double quotes: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The shellcheck SC2086 suppression shows the word splitting is deliberate. Even so, a workflow-controlled value is split on whitespace and glob-expanded unquoted. The fix is to split it explicitly and safely, e.g. `read -ra paths <<< "$AGENT_GUARD_PATHS"`, then pass "${paths[@]}" (with globbing disabled via `set -f` if needed).

Locations:

- `action.yml:103`

### github-env-injection (severity: high)

In the 'Install gitleaks if missing' step, an inherited process env var is written to $GITHUB_PATH without the required sanitization: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. The script does not set RUNNER_TEMP itself; it comes from the environment the composite action inherits. The value is not passed through `printf '%s' ... | tr -d '\n\r'` before the write, as the check requires. The fix is `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

script-injection: the 'Run Agent Guard' step no longer expands $AGENT_GUARD_PATHS unquoted. The value is read into an array with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true`, so it is still split on whitespace and newlines like before, but without globbing. An if-guard skips the read when the value is empty. The array is passed as ${paths[@]+"${paths[@]}"}, which keeps an empty array working under set -u on bash 3.2 (macOS). github-env-injection: the GITHUB_PATH write now runs through `printf '%s' ... | tr -d '\n\r'` before the echo.

