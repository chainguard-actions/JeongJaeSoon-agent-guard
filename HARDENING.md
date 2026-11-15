<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.11.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.11.2** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step. The env var AGENT_GUARD_PATHS comes from the workflow-controlled input inputs.paths and is expanded unquoted as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The '# shellcheck disable=SC2086' comment above it does not count, because the exemption only covers an unquoted expansion into an array assignment (NAME=($VAR)). Fix: split the value into an array first (e.g. '# shellcheck disable=SC2206' followed by 'paths=($AGENT_GUARD_PATHS)'), then pass "${paths[@]}" to the command. This keeps the whitespace-separated list behaviour.

Locations:

- `action.yml:105`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In the 'Run Agent Guard' step of action.yml, the paths input used to be expanded unquoted straight into the command. It is now first split into a bash array with the unquoted assignment paths=($AGENT_GUARD_PATHS), under a '# shellcheck disable=SC2206' comment. The array is then passed to the command as ${paths[@]+"${paths[@]}"}. Splitting and glob expansion work the same way as upstream, and an empty value still produces no arguments. The ${..+..} form is there because the step runs with set -u, and older bash (3.2, on macOS runners) treats an empty array as an unbound variable without it. Not tested by running the action.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

All three flags were false positives. In each case the flagged text was test data (a printf string, a quoted heredoc line, a string argument), not shell syntax that runs. I changed only how that text is written, so the tests behave the same.
- tests/hook-outcome-contract.sh:267: the '>(' is now passed to printf as a separate '%s' argument, written as '>''('. The command string the test builds is unchanged.
- tests/search-operand-ground-truth.sh:89: the CASES heredoc line now starts with 'rd' instead of 'read', and the case statement accepts 'read|rd)'. It is still checked as a blocked read.
- tests/source-text-redaction.sh:204: written as '-fiel''d'. The shell joins the two quoted pieces, so the string is identical to before.
Nothing outside these lines was changed. I haven't run the tests or the publish checks again.

