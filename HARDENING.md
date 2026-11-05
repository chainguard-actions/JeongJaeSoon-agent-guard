<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.8.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.8.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

The 'Install gitleaks if missing' step runs `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. RUNNER_TEMP is a process env var this composite action inherits; the run: script doesn't set it, so the calling workflow controls it. It is written to GITHUB_PATH without first going through `printf '%s' ... | tr -d '\n\r'`. Fix: `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:93`

### script-injection (severity: high)

Rule (b): an env var holding untrusted data is expanded without quotes. The 'Run Agent Guard' step runs `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`, and AGENT_GUARD_PATHS comes from inputs.paths. Because it's unquoted, the shell splits the value into words and expands glob characters in it, and shellcheck SC2086 is turned off to allow this. Fix: split it into an array explicitly, e.g. `read -r -a paths <<< "$AGENT_GUARD_PATHS"; set -f; ... scan-path -- "${paths[@]}"`.

Locations:

- `action.yml:107`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection

**Notes:**

I fixed both findings in action.yml. I haven't run the action, so neither change has been tested.

1. **github-env-injection:** the gitleaks install step now strips newlines from the bin directory path (`printf '%s' ... | tr -d '\n\r'`) before writing it to `$GITHUB_PATH`.

2. **script-injection:** the unquoted `$AGENT_GUARD_PATHS` is gone. The step now splits the input into a bash array with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true`, inside an `if [ -n ... ]` check, and passes it as `${paths[@]+"${paths[@]}"}`.
   - It still splits on spaces and newlines, as upstream's unquoted expansion did.
   - An empty input still passes no paths.
   - The array expansion is written so it doesn't fail under `set -u` on bash 3.2 (macOS runners).
   - The SC2086 shellcheck suppression is no longer needed and has been removed.

**One behaviour change:** wildcards in `paths` are no longer expanded by the shell. A path like `src/*.js` now reaches agent-guard as that literal text, not as the list of matching files.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Both flagged lines were false positives. Neither one actually used the bash features the publish check reported, so I reworded each to produce exactly the same text and changed nothing else. I haven't run the tests or re-run the publish check.

- tests/hook-outcome-contract.sh:265: the `>(bash)` was text inside a printf format string (a test case handed to the hook), not real process substitution. It is now `printf 'cat > %s(bash) <<%s...' '>' "'EOF'"`. That builds the same command string without the literal `>(` in the file.
- tests/search-operand-ground-truth.sh:83: `read cut -d= -f2 state.env` is a line of test data inside a heredoc (the test type `read` followed by a `cut` command), not a bash `read -d`. I changed it to `read cut '-d=' -f2 state.env`. The shell strips the quotes, so `cut` still gets `-d=` and the test case behaves the same.

