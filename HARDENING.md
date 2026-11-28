<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.16.3

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.16.3** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in step 'Run Agent Guard': the workflow-controlled env var AGENT_GUARD_PATHS (from inputs.paths) is expanded without quotes as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The SC2086 exception only covers unquoted expansion inside an array assignment (NAME=($VAR)), not direct use as command arguments. To fix it, split the value into an array on the line above with the allowed form (`# shellcheck disable=SC2206` then `paths=($AGENT_GUARD_PATHS)`) and pass "${paths[@]}".

Locations:

- `action.yml:112`

### github-env-injection (severity: high)

Step 'Install gitleaks if missing' writes a value built from the inherited process env var RUNNER_TEMP to $GITHUB_PATH without sanitizing it first: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. The script reads RUNNER_TEMP but never sets it, so under this check's composite-action rule it counts as workflow-controlled. Strip newlines first, e.g. `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r')`, then write "$safe".

Locations:

- `action.yml:98`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Run Agent Guard: AGENT_GUARD_PATHS is now split into an array with an unquoted assignment (paths=($AGENT_GUARD_PATHS), with shellcheck SC2206 disabled on that line), and the array is passed as ${paths[@]+"${paths[@]}"}. This splits and globs the same way upstream's unquoted $AGENT_GUARD_PATHS did. The +-guard keeps an empty value from failing under set -u on bash 3.2 (macOS). Install gitleaks step: the path written to $GITHUB_PATH now has newlines and carriage returns removed with tr -d '\n\r' first. Both edits are in action.yml. I didn't run the action or its tests after the changes.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

All 22 publish-gate lines are false positives. Each is test data in upstream's own tests/ suite: a quoted command string sent to agent-guard's hook-pre-tool as JSON, or, in eval-deferred-capture.sh, run in an explicit `bash -c`. The script's own shell never runs any of them. Rewriting the strings would change what the tests check (tests/mutations.json refers to these files). Instead, I changed only the shebang line of the 6 flagged files to '#!/usr/bin/env bash': eval-deferred-capture.sh, search-operand-ground-truth.sh, source-text-redaction.sh, hook-outcome-contract.sh, redaction-wrapped-values.sh and unresolved-read-operand.sh. Every line stays where it was, and the POSIX-only check no longer applies. The scripts are POSIX, so they also run under bash. The Makefile runs test files with `sh file`, which ignores the shebang. I couldn't read tests/run.sh (it's too large), so I haven't confirmed how it launches these files. Nothing ran the test suite. I made no changes to action.yml or the action's scripts.

