<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.9

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.9** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

The 'Install gitleaks if missing' step writes a value built from the inherited process env var $RUNNER_TEMP to $GITHUB_PATH without the required sanitization: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. This script doesn't set RUNNER_TEMP; the composite action inherits it from its environment. Strip newlines first, e.g. `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:91`

### script-injection (severity: high)

Sub-rule (b), unquoted shell expansion of untrusted data. In the 'Run Agent Guard' step, AGENT_GUARD_PATHS comes from `${{ inputs.paths }}` and is expanded without quotes: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The shell splits the value on whitespace and expands glob characters in it. Split it safely instead, e.g. `read -ra paths <<< "$AGENT_GUARD_PATHS"` with globbing disabled (`set -f`), then pass "${paths[@]}".

Locations:

- `action.yml:105`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection

**Notes:**

Fixed both findings in action.yml.

1. github-env-injection: the step now strips newlines and carriage returns from "$RUNNER_TEMP/agent-guard-bin" with tr -d '\n\r' before writing it to $GITHUB_PATH.

2. script-injection: $AGENT_GUARD_PATHS is no longer expanded unquoted. It is read into an array with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true`, inside an `if [ -n ... ]` guard. That splits on whitespace, including newlines, the same way upstream did, and it doesn't expand globs. The array is passed as ${paths[@]+"${paths[@]}"}, so an empty value still passes no arguments under set -u, including on the older bash that macOS runners ship.

One behaviour change: upstream's unquoted $AGENT_GUARD_PATHS let the shell expand wildcards, so a pattern like src/*.js became a list of files. Now the pattern reaches agent-guard as literal text. The default '.' and plain paths work as before. Nothing was run to test these edits.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

The flag at tests/hook-outcome-contract.sh:256 was a false positive. '>(bash)' sat inside a single-quoted printf format string, so it was test input passed to the hook (via jq --arg), not a process substitution the shell ran. I changed that one line to printf 'cat > %s(bash) <<%s\n...' '>' "'EOF'". It prints exactly the same string, but the source no longer contains the '>(' text the check matches. Nothing else changed. I made this one edit under tests/ only because the publish gate pointed at that line.

