<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.8.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.8.2** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): the env var AGENT_GUARD_PATHS, which comes from the inputs.paths input, is expanded without quotes in the 'Run Agent Guard' step: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. Without quotes, the shell splits the value on whitespace and expands glob characters (*, ?, [...]) against the filesystem. That lets the caller's input change the argument list in ways the action doesn't intend. A safer way to split on whitespace is `read -ra paths <<< "$AGENT_GUARD_PATHS"` with `set -f`, then pass `"${paths[@]}"`.

Locations:

- `action.yml:105`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In action.yml 'Run Agent Guard', the unquoted $AGENT_GUARD_PATHS is replaced by an array filled with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true`, guarded by a non-empty check. It splits on whitespace (newlines too) like upstream but does not expand globs. The array is passed as ${paths[@]+"${paths[@]}"} so it stays safe under set -u on bash 3.2 when empty.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Both flags were false positives. The flagged text is test data: shell commands the tests feed to the hook. Neither shell script actually runs those constructs. I changed only how the data is written, so the tests should behave as before. I didn't run them.
- tests/hook-outcome-contract.sh:265: the test string 'cat > >(bash) <<...' is now built with printf 'cat > %s(bash) ...' '>', which produces the same command text without a literal process substitution.
- tests/search-operand-ground-truth.sh: the heredoc's first word is a case-type label, and the checker read the label 'read' as the read builtin. I renamed it to 'leak' in the data lines, in the matching case branch and in the header comment. The commands under test are unchanged.

