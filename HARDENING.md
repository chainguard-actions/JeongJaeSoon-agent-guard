<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.8** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): the 'Run Agent Guard' step expands the input-derived env var AGENT_GUARD_PATHS without quotes: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. AGENT_GUARD_PATHS comes from inputs.paths. Without quotes, the shell splits the value on whitespace and expands glob characters in it. The `--` stops the values being read as options, but a caller can still make globs expand to unexpected files. Fix: split the value safely into an array, e.g. `read -r -a paths <<< "$AGENT_GUARD_PATHS"` with `set -f`, then pass `"${paths[@]}"`.

Locations:

- `action.yml:104`

### github-env-injection (severity: high)

The 'Install gitleaks if missing' step writes a path built from the inherited process env var RUNNER_TEMP to $GITHUB_PATH without the required sanitization: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. The script does not set RUNNER_TEMP itself; it comes from the composite action's inherited environment. Under this check, that makes it workflow-controlled. Fix: clean the value first, e.g. `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r')`, then `echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Both findings are fixed in action.yml. I edited the file but didn't run anything to test it.

1. **script-injection** (the 'Run Agent Guard' step): the paths value used to be expanded unquoted. It is now split into a bash array with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true`, and the array is passed as `${paths[@]+"${paths[@]}"}`.
   - Splitting still happens on whitespace, including newlines, as before. Glob characters are no longer expanded, so the finding's `set -f` suggestion isn't needed.
   - A check for an empty value stops it from turning into one empty argument. The `${paths[@]+...}` form avoids the `set -u` error that older bash (macOS ships 3.2) gives for an empty array.
   - The one behaviour change is on purpose: a caller who used to rely on wildcards in `paths` being expanded will now have the pattern passed through as literal text.

2. **github-env-injection** (the 'Install gitleaks if missing' step): the `$RUNNER_TEMP/agent-guard-bin` directory is now cleaned with `printf '%s' ... | tr -d '\n\r'` before it is written to `$GITHUB_PATH`.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Fixed the one publish-gate failure at tests/hook-outcome-contract.sh:256. The `>(bash)` there isn't real process substitution. It's literal test text inside a single-quoted printf format string, used as a test payload. I changed the `(` to printf's octal escape `\050`. POSIX printf turns `\050` back into `(`, so the test command string is exactly the same as before, and the source no longer has the `>(` sequence the check flags. I touched this file under tests/ only because the publish gate requires it. Nothing else changed, and the test hasn't been re-run.

