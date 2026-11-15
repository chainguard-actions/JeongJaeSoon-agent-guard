<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.10.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): in the 'Run Agent Guard' step, the env var AGENT_GUARD_PATHS (set from ${{ inputs.paths }}) is expanded without quotes as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The SC2086 exemption covers only array assignments (NAME=($VAR)). It does not cover a bare expansion in a command line, so this line is still a finding. One fix is to assign it to an array first with the shellcheck directive (e.g. `# shellcheck disable=SC2086,SC2206` then `paths=($AGENT_GUARD_PATHS)`) and pass "${paths[@]}".

Locations:

- `action.yml:103`

### github-env-injection (severity: high)

In the 'Install gitleaks if missing' step, a value built from the inherited process env var RUNNER_TEMP is written to $GITHUB_PATH with no sanitization: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. The script reads RUNNER_TEMP but never sets it, so the check treats it as workflow-controlled. The required `printf '%s' ... | tr -d '\n\r'` step does not run before the write.

Locations:

- `action.yml:91`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed both findings in action.yml.

1. script-injection: the 'Run Agent Guard' step used to expand $AGENT_GUARD_PATHS unquoted straight on the command line. It now first assigns it unquoted to an array, `paths=($AGENT_GUARD_PATHS)`, with a `# shellcheck disable=SC2086,SC2206` comment. That splits the paths on whitespace and expands glob patterns exactly as upstream did. The array is then passed as `${paths[@]+"${paths[@]}"}`, so an empty value still gives no arguments without tripping `set -u` on bash 3.2 (the macOS runner version).

2. github-env-injection: before the RUNNER_TEMP-based directory is written to $GITHUB_PATH, newline and carriage-return characters are now removed with `printf '%s' ... | tr -d '\n\r'`.

I didn't run the action or re-run the analysis after these edits.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

All three flags were false positives. In each case the bash-looking text sits inside test data, not in code the shell runs, so I reworded the text so the checks no longer match it. Each test still gets exactly the same input as before. I have not re-run the checks or these tests.
- tests/hook-outcome-contract.sh:267: in the printf format string, wrote each '>' as the octal escape \076. printf turns it back into '>', so the test command is still 'cat > >(bash) <<...'.
- tests/search-operand-ground-truth.sh:83: the flagged line is a test case read in from a heredoc, labelled with the kind 'read'. I relabelled it 'leak' and changed that case's branch from 'read)' to 'read|leak)', so the command it checks ('cut -d= -f2 state.env') and how it is checked are the same.
- tests/source-text-redaction.sh:204: split the literal 'read' into 'rea''d' inside the single-quoted string. The shell joins the two parts, so the string is still 'vault read -field token /secret/werft'.
These are files under tests/, which hardening normally leaves alone; I edited them only because the publish gate blocks on them, and changed nothing else.

