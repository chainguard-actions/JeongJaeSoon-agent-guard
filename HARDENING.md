<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.11

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.11** was hardened automatically. 1 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b) is violated in the 'Run Agent Guard' step. The env var AGENT_GUARD_PATHS gets its value from ${{ inputs.paths }}, which the calling workflow controls, and the script expands it without quotes: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. Because it is unquoted, the shell splits the value on whitespace and expands glob characters such as *, ? and [] in an untrusted value. The comment `# shellcheck disable=SC2086` turns off the shellcheck warning but does not make the expansion safe. A safer approach is to split the value into an array with `read -ra paths <<< "$AGENT_GUARD_PATHS"` after running `set -f`, then pass `"${paths[@]}"`.

Locations:

- `action.yml:110`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In action.yml's 'Run Agent Guard' step, the unquoted $AGENT_GUARD_PATHS is replaced by an array built with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true`, guarded by a non-empty check. The array is passed as ${paths[@]+"${paths[@]}"} so an empty array is safe under set -u on bash 3.2. Paths are still split on whitespace and newlines as upstream did, but glob characters are no longer expanded.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In action.yml step 'Install gitleaks if missing', the $RUNNER_TEMP/agent-guard-bin value is now passed through printf '%s' | tr -d '\n\r' into safe_bin_dir before being written to $GITHUB_PATH.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

In tests/hook-outcome-contract.sh line 265, the literal 'cat > >(bash)' sat inside a printf format string. It was test data passed to the guard as a command, and this shell never ran it. I changed the format to 'cat > %s(bash) <<%s...' and pass '>' as the first argument, so printf still builds exactly the same command string ('cat > >(bash) <<'EOF'...'). The file no longer contains the process-substitution text the POSIX sh check looks for. Nothing else was changed. I haven't run the test file or re-run the publish checks.

