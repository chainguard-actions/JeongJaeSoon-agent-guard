<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.4** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b), unquoted expansion of untrusted data. In the 'Run Agent Guard' step, AGENT_GUARD_PATHS comes from ${{ inputs.paths }} and is expanded without quotes: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The '--' stops the value being read as options. However, the value is still split on whitespace and glob characters in it are expanded, and the rule requires the expansion to be double-quoted. A safe fix is to split explicitly, for example `read -ra paths <<< "$AGENT_GUARD_PATHS"` followed by `"${paths[@]}"`, with globbing turned off (set -f).

Locations:

- `action.yml:105`

### github-env-injection (severity: high)

In the 'Install gitleaks if missing' step, an inherited process env var is written to $GITHUB_PATH without sanitization: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. The script reads RUNNER_TEMP but never sets it. In a composite action, the check treats any such inherited value as controlled by the calling workflow. The required `printf '%s' ... | tr -d '\n\r'` step is not applied before the write. Fix: `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

script-injection: the step no longer expands $AGENT_GUARD_PATHS unquoted. It now reads the value into an array with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true`, which splits on any whitespace, newlines included, the same way upstream's unquoted expansion did. The read only runs when the value is non-empty. The array is passed after '--' as ${paths[@]+"${paths[@]}"}, so an empty array works under set -u even with bash 3.2 on macOS. Unlike upstream, glob characters in paths are no longer expanded. I used `read -d ''` rather than the `read -ra` the finding suggested, because `read -ra` reads only the first line and would drop paths given one per line. github-env-injection: the step now strips CR/LF from "$RUNNER_TEMP/agent-guard-bin" with printf | tr -d '\n\r' before writing it to $GITHUB_PATH.

