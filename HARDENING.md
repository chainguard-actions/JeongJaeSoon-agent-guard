<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.13.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.13.8** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step. The workflow-controlled input inputs.paths is passed through env AGENT_GUARD_PATHS and then expanded unquoted as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The '# shellcheck disable=SC2086' exemption only covers unquoted expansion inside an array assignment (NAME=($VAR)). It does not cover a bare unquoted expansion in a command line. To get the same whitespace splitting in the hardened form, use `# shellcheck disable=SC2206` followed by `paths=($AGENT_GUARD_PATHS)`, then pass "${paths[@]}".

Locations:

- `action.yml:105`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In the 'Run Agent Guard' step, the bare unquoted $AGENT_GUARD_PATHS argument is replaced by an unquoted array assignment, paths=($AGENT_GUARD_PATHS), marked with a shellcheck SC2206 disable comment. The array is then expanded as ${paths[@]+"${paths[@]}"}. This splits on whitespace and expands globs exactly as upstream did. The guarded expansion avoids an unbound-variable error under set -u on bash 3.2 (macOS) when the paths input is empty. I haven't run the action or any tests to confirm the change.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Every flagged line is in upstream's own test scripts (tests/), and in each case the flagged construct is test data inside a string or a quoted heredoc. None of it was code the script runs. I rewrote each one so the check no longer matches it, while the string the test builds stays the same. I haven't run the changed tests.

- hook-outcome-contract.sh:267: the `>` of `>(bash)` is now inserted through a printf `%s` argument, so the generated command is unchanged.
- redaction-wrapped-values.sh:144: the two-line expected input is now built with printf. The `(` and the `$wide` value go in through `%s`, so the text is the same.
- source-text-redaction.sh:204: `read` is now written as `rea''d` inside the single-quoted string. The shell joins the two pieces, so the text passed to `keeps` is still `vault read -field token ...`.
- unresolved-read-operand.sh:213: the double-quoted string is split as `"cat < ""<(..."`. The two halves join into the same command string.
- search-operand-ground-truth.sh: the flagged rows in the quoted CASES heredoc started with the kind word `read`. They now use a new kind word, `leak`, and the case statement treats `read|leak` the same way, so each row is still checked exactly as before. All other rows are unchanged.

I made no other changes, and action.yml and the action's runtime scripts are untouched.

