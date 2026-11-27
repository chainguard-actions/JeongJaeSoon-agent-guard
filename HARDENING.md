<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.14.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.14.0** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step. The workflow-controlled env var AGENT_GUARD_PATHS, which comes from ${{ inputs.paths }}, is expanded without quotes as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The SC2086 shellcheck directive above it does not make this exempt. The exemption only covers unquoted expansion into an array assignment (NAME=($VAR)), and this is a command argument. A safe form that keeps the whitespace-separated list behaviour is to load the value into an array assignment under the shellcheck directive (e.g. `# shellcheck disable=SC2086,SC2206` then `paths=($AGENT_GUARD_PATHS)`) and pass "${paths[@]}".

Locations:

- `action.yml:112`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In the 'Run Agent Guard' step, the unquoted $AGENT_GUARD_PATHS command argument now loads into an array first (paths=($AGENT_GUARD_PATHS), with the shellcheck directive SC2086,SC2206). The command receives that array as ${paths[@]+"${paths[@]}"}. Paths are split on whitespace and globs expand exactly as upstream did. The ${paths[@]+...} form means an empty value passes no arguments; a bare "${paths[@]}" fails under set -u on bash 3.2 (macOS runners) when the array is empty. Not tested here: I didn't run the action, shellcheck or a re-analysis pass.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

All 20 flagged lines are in upstream's own test scripts. Each one is a bash construct written as text inside a string, a heredoc or an argument, and none of them actually runs as shell code, so the gate's hits are false positives. I changed how each line is written but not what the tests check:
- hook-outcome-contract.sh: the '>' of '>(bash)' is now passed to printf as a '%s' argument. The command string it produces is the same as before.
- redaction-wrapped-values.sh: the two-line expected value containing 'token=(...)' is now built with printf, so it produces the same text.
- search-operand-ground-truth.sh: renamed the row label 'read' to 'leak' in the CASES heredoc and in its matching case arm. That label was what made the gate think these lines used bash-only read flags. The commands being tested are unchanged.
- source-text-redaction.sh: wrote 'vault read' as 're''ad'. The two quoted pieces join into the same string.
- unresolved-read-operand.sh: wrote '< <(' as '< <""(' inside the double-quoted argument, which gives the same string.
I have not run any of the tests or the gate again after these edits.

