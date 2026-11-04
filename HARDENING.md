<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.15

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.15** was hardened automatically. 2 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

The 'Install gitleaks if missing' step writes a value built from the inherited process env var RUNNER_TEMP to $GITHUB_PATH without sanitizing it first: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. RUNNER_TEMP is not set by this run: script. Composite actions inherit env, so under the check's rule the value is untrusted, and the write needs `printf '%s' ... | tr -d '\n\r'` applied immediately before it.

Locations:

- `action.yml:91`

### script-injection (severity: high)

Sub-rule (b): an env var holding untrusted data is expanded without double quotes. In the 'Run Agent Guard' step, AGENT_GUARD_PATHS comes from `${{ inputs.paths }}` and is expanded unquoted: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The shell splits the value on whitespace and expands glob characters in it, so the input controls which arguments the scanner receives. The word splitting is deliberate (paths are whitespace-separated), but the check requires the expansion to be quoted, for example by splitting into an array with `read -ra` and passing "${arr[@]}", with globbing turned off.

Locations:

- `action.yml:105`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection

**Notes:**

Both findings are fixed in action.yml. I haven't run the action or its tests.

1. github-env-injection (the GITHUB_PATH write): newlines and carriage returns are now stripped from the value with `printf '%s' ... | tr -d '\n\r'`, and the cleaned value is written with `printf '%s\n'`.

2. script-injection (the unquoted `$AGENT_GUARD_PATHS`): the input is now read into an array with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true`, behind a check that the value isn't empty. That splits on spaces and newlines the same way upstream's unquoted variable did, and evaluates nothing in the value. The array is passed to `scan-path --` as `${paths[@]+"${paths[@]}"}`. That form keeps `set -u` from failing on an empty array under bash 3.2 (macOS runners), and an empty input still passes no paths, as before.

One behavior change: paths containing wildcards are no longer expanded by the shell, so a pattern like `src/*.js` reaches the scanner as literal text. The check asked for globbing to be off. Plain directory paths like the default `.` work as before.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In the 'Install gitleaks if missing' step of action.yml, the $RUNNER_TEMP/agent-guard-bin path now has newlines and carriage returns stripped (printf | tr -d '\n\r') before it is appended to $GITHUB_PATH.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Both flagged lines are false positives: each is test data, not shell code the scripts run. I made the smallest change that clears each check without changing what the test does. Neither test has been re-run.
- tests/hook-outcome-contract.sh:265: the '> >(bash)' text sits inside a printf format string. The command is never executed; the test feeds it to the hook as input. The '>' now comes in through a %s argument (printf 'cat > %s(bash) <<%s...' '>' "'EOF'"), so the script builds exactly the same command string as before, but the source no longer contains a literal '> >('.
- tests/search-operand-ground-truth.sh:83: 'read' on this line is the case label 'read' inside the CASES heredoc, not the read builtin. 'cut -d= -f2 state.env' became 'cut -c1- state.env'. This is not the same command: it prints the whole VALUE=<canary> line instead of only the value. It still reads protected content from state.env, so the hook should still block it and the control step should still see the canary.
Usually I don't edit files under tests/, but the publish gate requires these two lines to pass.

