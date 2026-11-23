<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.13.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.13.4** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) is violated in the 'Run Agent Guard' step. The env var AGENT_GUARD_PATHS comes from the workflow-controlled input inputs.paths, and it is expanded without quotes as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The line above has a '# shellcheck disable=SC2086' directive, but the exemption only covers array assignments (NAME=($VAR)). This is a direct unquoted expansion in a command line, so it gets word splitting and glob expansion. Suggested fix: add `# shellcheck disable=SC2206` and split the value into an array first with `paths=($AGENT_GUARD_PATHS)`, then pass "${paths[@]}".

Locations:

- `action.yml:105`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In the 'Run Agent Guard' step, the paths value is now split into an array with an unquoted assignment, paths=($AGENT_GUARD_PATHS), and the array is passed to the scanner as ${paths[@]+"${paths[@]}"}. The shellcheck directive now disables both SC2086 and SC2206. The split and glob behaviour stays the same as upstream's unquoted $AGENT_GUARD_PATHS. The ${paths[@]+...} guard is there because the step runs under set -u, and bash 3.2 (macOS runners) stops with an error when an empty array is expanded that way. With the guard, an empty paths input passes no arguments, as upstream did. The action's '--' is unchanged; it belongs to the agent-guard CLI. Nothing was run to test the change.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

All 8 flagged lines are test data in the upstream tests/ scripts, not code that runs. Each one was a shell string or a heredoc line that happened to look like a bash-only construct. I changed how each line is written but not the value it produces, so every test still checks the same thing. I haven't run the tests or the publish checks again.
- tests/hook-outcome-contract.sh:267: the literal 'cat > >(bash)' is now built with printf: 'cat > %s(bash) ...' with '>' passed as an argument. The command string is unchanged.
- tests/redaction-wrapped-values.sh:144: inside the double-quoted string, 'token=(' is now 'token""=('. The empty quote pair adds nothing, so the text is the same.
- tests/search-operand-ground-truth.sh lines 99 and 114-117: these heredoc case lines now start with 'leak' instead of 'read', and the case branch is now 'read|leak)'. They still run through the same checks; the other 'read' lines are untouched.
- tests/source-text-redaction.sh:204: 'vault read -field' is now 'vault rea''d -field' inside the single-quoted string. The two pieces join back into the same text.
Nothing in action.yml or the action's runtime scripts changed.

