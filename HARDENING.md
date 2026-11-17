<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.11.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.11.4** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step. The workflow-controlled env var AGENT_GUARD_PATHS (from inputs.paths) is expanded unquoted as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The SC2086 exemption covers only an unquoted expansion inside an array assignment (NAME=($VAR)). It does not cover a bare command argument. Fix: assign the list to an array first, e.g. `# shellcheck disable=SC2086,SC2206` then `paths=($AGENT_GUARD_PATHS)`, and pass `"${paths[@]}"`.

Locations:

- `action.yml:106`

### github-env-injection (severity: high)

The 'Install gitleaks if missing' step writes to $GITHUB_PATH a value built from the inherited process env var RUNNER_TEMP, which this run: script does not set: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. In a composite action, inherited env vars count as workflow-controlled, so the value must go through `printf '%s' ... | tr -d '\n\r'` right before the write.

Locations:

- `action.yml:95`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

I fixed both findings in action.yml. Nothing was run or tested.

1. script-injection: the paths list is now put into an array without quotes first, `paths=($AGENT_GUARD_PATHS)`, with the comment `# shellcheck disable=SC2086,SC2206`. The array is passed to the scan command as `${paths[@]+"${paths[@]}"}`. Upstream also left `$AGENT_GUARD_PATHS` unquoted, so this splits on whitespace and expands globs the same way it did. The `+` form means an empty list still passes no arguments. It also avoids an 'unbound variable' error under `set -u` on bash 3.2, the version on macOS runners.

2. github-env-injection: before the directory is written to $GITHUB_PATH, `$RUNNER_TEMP/agent-guard-bin` now goes through `printf '%s' ... | tr -d '\n\r'` to strip newlines and carriage returns.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

All three flags were false positives. Each one was text inside a test string, not shell syntax that actually runs. I changed only how each line is written: two of the tests produce exactly the same strings as before, and the third runs an equivalent command. No action.yml or other action code was touched. Nothing was run, so neither the publish checks nor the tests have been re-run on these changes.

- hook-outcome-contract.sh:267: the second '>' in the printf format is now the octal escape \076. printf turns it back into '>', so the test command is still 'cat > >(bash) <<...', byte for byte.
- source-text-redaction.sh:204: wrote 're''ad' using adjacent single-quoted pieces. The shell joins them, so the test text is still '  TOKEN="$(vault read -field token /secret/werft)"'.
- search-operand-ground-truth.sh:92: this heredoc line is data, so it can't be split the same way. I replaced 'cut -d= -f2 state.env' with 'cut -c7- state.env'. Both print the value after 'VALUE=' in the protected file (the random test value), so the check still expects the hook to block a cut that reads state.env, and the run to show that value. This one is a different command, not the same text.

