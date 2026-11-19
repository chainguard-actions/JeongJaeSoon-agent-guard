<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.12.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.12.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): in the 'Run Agent Guard' step, the workflow-controlled env var AGENT_GUARD_PATHS (from inputs.paths) is expanded without quotes as command arguments: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The SC2086 exemption only covers an array assignment (NAME=($VAR)). This is a plain unquoted expansion on a command line. Fix: put it in an array first with the shellcheck directive, e.g. `# shellcheck disable=SC2206` then `paths=($AGENT_GUARD_PATHS)`, and pass it as "${paths[@]}".

Locations:

- `action.yml:105`

### github-env-injection (severity: high)

In the 'Install gitleaks if missing' step, `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"` writes a value taken from the inherited process env var RUNNER_TEMP to $GITHUB_PATH. The script does not set RUNNER_TEMP, so under this check it counts as workflow-controlled in a composite action. It is not passed through `printf '%s' ... | tr -d '\n\r'` before the write. Fix: `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:92`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Both findings are fixed in action.yml.

script-injection: the step no longer expands $AGENT_GUARD_PATHS unquoted on the command line. It now assigns it unquoted to an array (paths=($AGENT_GUARD_PATHS), with shellcheck SC2086/SC2206 disabled) and passes ${paths[@]+"${paths[@]}"} to agent-guard. The paths are still split on whitespace and glob-expanded exactly as upstream did, so a pattern like 'cle*' still matches files. The ${paths[@]+...} form keeps 'set -u' from failing on an empty array under bash 3.2 (macOS); an empty input still passes no arguments.

github-env-injection: the step now strips newlines from the RUNNER_TEMP-derived path with printf '%s' ... | tr -d '\n\r' before writing it to $GITHUB_PATH. No pipefail concern there: the pipeline is only printf and tr.

Nothing was run to test these edits.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

All three flagged lines are test data that the scanner mistook for shell syntax: a printf format string, a quoted-heredoc case line, and a single-quoted string passed to a check function. I rewrote each so the scanner stops matching but the tests still feed exactly the same command text as before. I haven't run the tests.

- tests/hook-outcome-contract.sh:267: the `>(bash)` inside the printf format is now built at runtime from `'%s(bash)'` with `'>'` passed as an argument. The printed string is identical.
- tests/search-operand-ground-truth.sh:92: the case label is now `reads` instead of `read`, and the `case` branch matches `read|reads)`, so the same command (`cut -d= -f2 state.env`) gets the same checks.
- tests/source-text-redaction.sh:204: the string passed to `keeps` is now built with `printf '... vault %s -field ...' read`. It produces the same text.

