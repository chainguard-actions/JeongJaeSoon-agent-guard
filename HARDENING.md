<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.2** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b), unquoted shell variable expansion. In the 'Run Agent Guard' step, AGENT_GUARD_PATHS comes from the workflow-controlled inputs.paths and is expanded without quotes: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The word splitting is intentional (there is a shellcheck disable), but the unquoted expansion also lets the shell expand glob characters in the value. Fix: split into an array, e.g. `read -r -a paths <<< "$AGENT_GUARD_PATHS"`, and pass it as "${paths[@]}". Glob expansion can be turned off with set -f first.

Locations:

- `action.yml:106`

### github-env-injection (severity: high)

In the 'Install gitleaks if missing' step (composite action), `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"` writes a value built from an inherited process env var (RUNNER_TEMP). That var is not set in the same run: script, and the line has no `printf '%s' ... | tr -d '\n\r'` sanitization before the write. Fix: `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:92`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

I fixed both findings in action.yml. I haven't run or tested the action after the change.

**script-injection:** The paths input is no longer expanded unquoted. It is now split into a bash array with `read -r -d '' -a ... || true`, so it still splits on spaces and newlines like before. One thing works differently: wildcards in a path are no longer expanded by the shell, so they reach the tool as literal text. That was the point of the finding.
- The `|| true` is needed because `read -d ''` returns 1 at the end of input, which would otherwise fail the step under `set -e`.
- The split only runs when the input isn't empty.
- The array is passed as `${paths[@]+"${paths[@]}"}` so an empty list doesn't trip `set -u` on bash 3.2 (the version on macOS runners).

**github-env-injection:** Newlines are now stripped from the gitleaks directory path (`printf '%s' | tr -d '\n\r'`) before it is written to $GITHUB_PATH.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Removed the leftover old command text (`lugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`) at the end of the Run Agent Guard step. This text left a quote open and expanded inputs.paths without quoting. The final line now reads `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- ${paths[@]+"${paths[@]}"}`. The whitespace split that uses read -d '' is unchanged. Also cleaned up a duplicated comment marker.

