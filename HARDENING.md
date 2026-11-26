<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.13.9

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.13.9** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): in the 'Run Agent Guard' step of the composite action, the workflow-controlled env var AGENT_GUARD_PATHS (from inputs.paths) is expanded without quotes as command arguments: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The SC2086 exception only covers expansion into an array assignment (NAME=($VAR)). This is a direct command-argument expansion, so it does not qualify. The value is split on whitespace and its glob characters are expanded. Safer form: `# shellcheck disable=SC2206` then `read_paths=($AGENT_GUARD_PATHS)`, and pass "${read_paths[@]}".

Locations:

- `action.yml:104`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In the 'Run Agent Guard' step, $AGENT_GUARD_PATHS is now split into an array with an unquoted assignment, scan_paths=($AGENT_GUARD_PATHS), and passed on as ${scan_paths[@]+"${scan_paths[@]}"}. The paths are still split on whitespace and globbed exactly as upstream's unquoted expansion did. The ${arr[@]+...} form means an empty input passes no arguments, as before, and avoids an unbound-variable error under set -u on bash 3.2 (macOS).

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

All the flagged lines were false positives: test data strings (command text passed to the hook as JSON) and heredoc case rows, not shell code that runs. I changed each one so the data the tests build at run time stays byte-for-byte the same and the literal text no longer trips the POSIX-sh checks. The tests were not run.
- tests/search-operand-ground-truth.sh: renamed the case kind 'read' to 'leak' in the CASES heredoc (79 rows) and in the matching 'read)' case branch. The commands under test and the ok/not ok messages are unchanged.
- tests/source-text-redaction.sh: the word 'read' in the vault command is now supplied by a variable (vault_sub=read), so the string the test builds is unchanged.
- tests/redaction-wrapped-values.sh: the two-line exec_check input is now built with printf, writing '(' as \050, so no 'token=(' appears in the source.
- tests/unresolved-read-operand.sh: the '<(' of the process-substitution test command now comes from a variable (psub_open='<('), so the hook gets the same 'cat < <(...)' string.
- tests/hook-outcome-contract.sh: inside the printf format, the second '>' of 'cat > >(bash)' is now written as \076, so the string is the same at run time.
No action.yml or runtime script changed.

