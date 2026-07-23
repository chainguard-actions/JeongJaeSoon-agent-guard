<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.9.0** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step: the env var `$AGENT_GUARD_PATHS` (sourced from `${{ inputs.paths }}`, a user-controlled input) is expanded **unquoted** in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker who controls the `paths` input can inject shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, glob characters, etc.) to execute arbitrary commands. The inline comment acknowledges the unquoted expansion is intentional for word-splitting, but this does not mitigate the injection risk. The value should be passed via a properly quoted array or a safe argument-splitting mechanism.

Locations:

- `action.yml:96`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml (line 96). The unquoted `$AGENT_GUARD_PATHS` expansion (`-- $AGENT_GUARD_PATHS`) was replaced with a safe bash array approach: `IFS=' ' read -ra _paths <<< "$AGENT_GUARD_PATHS"` followed by `"${_paths[@]}"`. This preserves the intended word-splitting behavior for multiple space-separated paths while preventing attackers from injecting shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.) through the `paths` input.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed all 15 script injection locations in .github/workflows/release.yml by moving every ${{ }} expression out of run: shell strings and into the step's env: block. Each expression is now referenced as a plain environment variable in the shell script (e.g., $INPUT_VERSION, $INPUT_BUMP, $VER_VERSION, $VER_BRANCH, $VER_PREVIOUS, $GITHUB_ACTOR, $INPUT_DRY_RUN, $PR_URL, $VER_MAJOR). This prevents attacker-controlled values from being interpreted as shell commands.

