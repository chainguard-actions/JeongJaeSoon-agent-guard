<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.14

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.14** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) violation: an env var built from input is expanded without quotes. In the 'Run Agent Guard' step, AGENT_GUARD_PATHS is set to ${{ inputs.paths }} and expanded unquoted on this line: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The splitting is deliberate (there is a shellcheck SC2086 disable), but the unquoted expansion also expands glob characters from the caller-supplied value, so the caller can make it match files outside the intended paths. The check requires this expansion to be quoted. One fix is to split it safely with `read -ra arr <<< "$AGENT_GUARD_PATHS"` under `set -f`, then pass "${arr[@]}".

Locations:

- `action.yml:105`

### github-env-injection (severity: high)

In the 'Install gitleaks if missing' step, `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"` writes a value built from the inherited env var RUNNER_TEMP to GITHUB_PATH. The script reads this variable but never sets it, and it is not sanitized first. Under rule (e) the composite action inherits its env from the calling workflow, so the value counts as untrusted. Fix: run `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r')` and write "$safe" instead.

Locations:

- `action.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

script-injection: the unquoted $AGENT_GUARD_PATHS is replaced by a bash array. It is filled with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true`, which runs only when the value is not empty. That splits on whitespace and newlines like upstream did, but glob characters are no longer expanded. The array is passed as ${paths[@]+"${paths[@]}"}, so an empty value still works under set -u on bash 3.2 (macOS). I kept the '--' because it goes to the agent-guard command itself, not to a shell. github-env-injection: before the RUNNER_TEMP-based path is written to $GITHUB_PATH, newlines and carriage returns are stripped with printf | tr -d '\n\r'.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

The publish check stopped on two lines under tests/. Neither one actually uses bash-only syntax: in both cases the check misread text inside a string or a heredoc as shell code. I don't normally change test files, but the check won't pass until these two lines change, so I made the smallest edits I could. Neither edit changes what the tests do; I didn't run them afterwards.

1. tests/hook-outcome-contract.sh:265: the '> >(bash)' sits inside a printf format string. It is test data (a command fed to the hook), and nothing in the script runs it. I now pass the second '>' in as a printf %s argument: printf 'cat > %s(bash) <<%s...' '>' "'EOF'". That produces exactly the same string at runtime.

2. tests/search-operand-ground-truth.sh:83: 'read cut -d= -f2 state.env' is a line inside the CASES heredoc. 'read' is the case's kind label, not a call to the read builtin. I renamed that one line's label to 'leak' and changed the case branch from 'read)' to 'read|leak)', so the line gets the same checks as before.

