<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.6** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation (unquoted expansion of untrusted data) in the 'Run Agent Guard' step. AGENT_GUARD_PATHS comes from ${{ inputs.paths }} and is expanded without quotes: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. Because it is unquoted, the shell splits the value on whitespace and expands glob characters (*, ?, [) inside it, so a caller can control which files and how many arguments reach the scanner. A '# shellcheck disable=SC2086' comment hides the warning. Fix: split the value into an array explicitly with globbing turned off, e.g. `read -r -a guard_paths <<< "$AGENT_GUARD_PATHS"` (with `set -f`), and pass `"${guard_paths[@]}"`.

Locations:

- `action.yml:105`

### github-env-injection (severity: high)

The 'Install gitleaks if missing' step writes a path built from an env var it did not set to $GITHUB_PATH without sanitizing it first: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. The rule treats any env var a composite action inherits rather than computes as untrusted, and this one is written with no `printf '%s' ... | tr -d '\n\r'` step before it. Note: RUNNER_TEMP is set by the runner, so the real risk is low. Fix: `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Both findings are fixed in action.yml. Nothing was run or tested.

- **script-injection:** The unquoted `$AGENT_GUARD_PATHS` and the shellcheck disable comment are gone. The paths are now split into an array with `read -r -d '' -a guard_paths <<< "$AGENT_GUARD_PATHS" || true`, which only runs when the value is non-empty. The array is passed as `${guard_paths[@]+"${guard_paths[@]}"}`. This still splits on any whitespace, newlines included, as upstream did, but no longer expands glob characters. The `+` form is there so an empty list doesn't trip `set -u` on bash 3.2 (macOS runners); in that case nothing is passed after `--`, same as before. One small difference from the finding's suggested fix: I used `read -d ''` instead of plain `read -ra`, because `read -ra` only reads the first line and would lose paths given one per line.
- **github-env-injection:** The `$RUNNER_TEMP` path now has newlines and carriage returns stripped (`printf '%s' ... | tr -d '\n\r'`) before it's written to `$GITHUB_PATH`.

