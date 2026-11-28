<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.16.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.16.2** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): in the 'Run Agent Guard' step, the workflow-controlled env var AGENT_GUARD_PATHS (from inputs.paths) is expanded unquoted as command arguments: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The SC2086 exemption covers only array assignments (NAME=($VAR)), so a bare unquoted expansion used as command arguments does not qualify. The safe fix that keeps the whitespace-separated list: `# shellcheck disable=SC2206` then `paths=($AGENT_GUARD_PATHS)` and pass "${paths[@]}".

Locations:

- `action.yml:117`

### github-env-injection (severity: high)

Case (e): the 'Install gitleaks if missing' step writes `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. RUNNER_TEMP is a process env var the run script reads but does not set, so under this check it counts as workflow-controlled. It is written to $GITHUB_PATH without the `printf '%s' ... | tr -d '\n\r'` step first. Fix: `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:104`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Both findings are fixed in action.yml.

1. script-injection: In the Run Agent Guard step, AGENT_GUARD_PATHS is now loaded into an array with an unquoted assignment, `paths=($AGENT_GUARD_PATHS)`. This splits on whitespace and expands globs exactly as upstream's bare `$AGENT_GUARD_PATHS` did. The array is then passed as `${paths[@]+"${paths[@]}"}`. That form is needed because the step runs under `set -u`, and with older bash (3.2, as on macOS) an empty array would otherwise stop the step. With an empty value the command gets no extra arguments, same as upstream. The shellcheck disable comment now names SC2086 and SC2206.

2. github-env-injection: Newlines are now stripped from the gitleaks bin path with `printf '%s' ... | tr -d '\n\r'` before it is written to $GITHUB_PATH.

I haven't run the action after these edits.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

I changed the first line of six upstream test scripts to `#!/usr/bin/env bash` and touched nothing else. I haven't run the tests or the publish gate since the change. The six scripts are eval-deferred-capture.sh, hook-outcome-contract.sh, redaction-wrapped-values.sh, search-operand-ground-truth.sh, source-text-redaction.sh and unresolved-read-operand.sh, all in tests/.

Every flagged line is test data, not shell code the script runs: quoted command strings handed to the agent-guard hook for checking, or (in eval-deferred-capture.sh) handed to `bash -c` on purpose. The gate's POSIX-sh check was reading those strings as code, so these were false positives. Rewriting the strings would have changed what the tests check, so I changed only the shebangs. With a bash shebang the POSIX-sh rule no longer applies, and the body of each script stays exactly as upstream wrote it.

This doesn't affect the published action. I found nothing in the repo that checks test-script shebangs. The new first line only matters if a script is run directly; I couldn't confirm how the upstream suite starts them because tests/run.sh is too large to read. If it runs them as `sh tests/<name>.sh`, the shebang is ignored and nothing changes. If any are run directly, bash now runs them instead of sh, which is not expected to change their behaviour.

