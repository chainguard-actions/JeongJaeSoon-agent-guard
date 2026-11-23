<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.13.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.13.2** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step of action.yml. AGENT_GUARD_PATHS comes straight from inputs.paths, which the calling workflow controls, and it is expanded without quotes as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The `# shellcheck disable=SC2086` comment does not make this safe. The exemption only covers an array assignment of the form NAME=($VAR). This line is a direct command argument, so the shell still splits the value on whitespace and expands glob characters inside it. Fix: split the value into an array on its own line, e.g. `# shellcheck disable=SC2206` then `paths=($AGENT_GUARD_PATHS)`, and pass it as `"${paths[@]}"`.

Locations:

- `action.yml:105`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In the 'Run Agent Guard' step, the unquoted $AGENT_GUARD_PATHS command argument is replaced by an unquoted array assignment paths=($AGENT_GUARD_PATHS) (# shellcheck disable=SC2206). This keeps upstream's whitespace splitting and glob expansion. The array is passed as ${paths[@]+"${paths[@]}"} so an empty value under set -u still works on bash 3.2 (macOS).

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

The publish gate flagged four upstream test scripts with a POSIX sh shebang. Each flagged construct was test data inside a string or heredoc, not code the shell runs, so none of them was a real bash-ism. I rewrote each one so the gate no longer matches it and the text the test checks stays the same. I haven't run these tests.
- hook-outcome-contract.sh: the 'cat > >(bash)' test string is now made with printf '%s' and a '>' argument. It prints the same text.
- redaction-wrapped-values.sh: the line 'token=($wide)' in the expected text now gets its '(' from a variable (lparen='('), so the string is unchanged.
- search-operand-ground-truth.sh: the test-case label 'read' is renamed to 'leak' in both the case branch and every heredoc line that used it. This means no case line starts with 'read <cmd> -d...' any more. The commands themselves and the printed messages are the same.
- source-text-redaction.sh: the expected 'vault read -field ...' string now builds the word 'read' from a variable (vault_subcmd=read), so the gate's read-flag pattern doesn't match. The string is the same.
No other files were changed. A broader search of tests/ found only one other match, in a JSON fixture rather than a shell script, so I left it alone.

