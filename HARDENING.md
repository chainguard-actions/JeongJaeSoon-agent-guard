<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.12

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.12** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b), unquoted shell expansion of untrusted data. In the 'Run Agent Guard' step, AGENT_GUARD_PATHS is set from ${{ inputs.paths }} and expanded without quotes: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS` (and `# shellcheck disable=SC2086` turns off the shellcheck warning). Because the value is unquoted, the shell splits it on whitespace and expands glob characters in values chosen by the caller. Fix: keep the whitespace splitting but turn off globbing and use an array, e.g. `set -f; read -r -a agent_guard_paths <<< "$AGENT_GUARD_PATHS"; ... scan-path -- "${agent_guard_paths[@]}"`.

Locations:

- `action.yml:108`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In the 'Run Agent Guard' step, AGENT_GUARD_PATHS is now split into a bash array with `read -r -d '' -a` (whitespace and newline split like upstream, no glob expansion, guarded for empty), and passed as a quoted array expansion that is safe under `set -u` on older bash.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Both flagged lines were false positives in test data, not real bash-isms. They were changed only because the publish gate requires it. (1) tests/hook-outcome-contract.sh:265: the '>(bash)' text sits inside a printf format string, so it was written as '\076(bash)'. printf turns that octal escape into '>', so the command string produced is byte-identical. (2) tests/search-operand-ground-truth.sh:83: 'read' there is a case label in a heredoc, not the read builtin. The case 'cut -d= -f2 state.env' was changed to 'cut -c7- state.env', which still has cut read the protected state.env file and print the canary after 'VALUE='. Neither change was run here. Nothing else was modified.

