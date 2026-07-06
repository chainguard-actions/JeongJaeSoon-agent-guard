<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard--/v1.8.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard--/v1.8.0** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step of action.yml, the env var $AGENT_GUARD_PATHS (which holds the untrusted input value ${{ inputs.paths }}) is expanded **unquoted** in the run: shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker-controlled `paths` input containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) could cause command injection. The shellcheck disable comment (SC2086) acknowledges the unquoted expansion but does not mitigate the security risk.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted expansion of $AGENT_GUARD_PATHS in the 'Run Agent Guard' step of action.yml. Replaced the unquoted `$AGENT_GUARD_PATHS` expansion (which had a shellcheck disable comment acknowledging the risk) with a safe bash array approach: `IFS=' ' read -ra paths_array <<< "$AGENT_GUARD_PATHS"` followed by `"${paths_array[@]}"`. This splits the space-separated paths into array elements without interpreting shell metacharacters, preventing command injection while preserving the ability to pass multiple paths as separate arguments.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script-injection and github-env-injection findings in .github/workflows/release.yml:

1. script-injection: Moved all ${{ }} expressions out of run: shell strings and into env: blocks for every affected step:
   - 'Compute next version': INPUT_VERSION and INPUT_BUMP env vars replace direct interpolation
   - 'Detect resume state': VER_VERSION env var replaces direct interpolation
   - 'Bump version in tracked files': VER_VERSION env var
   - 'Build CHANGELOG entry': VER_VERSION env var
   - 'Open release PR': VER_VERSION, VER_BRANCH, VER_PREVIOUS, GITHUB_ACTOR, INPUT_BUMP, INPUT_DRY_RUN env vars
   - 'Auto-merge release PR': PR_URL env var replaces direct interpolation
   - 'Wait for PR to merge': PR_URL env var
   - 'Tag and publish release': VER_VERSION and VER_MAJOR env vars

2. github-env-injection: Added sanitization (printf '%s' | tr -d '\n\r') before writing to $GITHUB_OUTPUT:
   - In 'Compute next version': safe_v, safe_MA, safe_cur variables sanitize version/major/branch/previous outputs
   - In 'Open release PR': safe_url sanitizes the PR URL before writing to GITHUB_OUTPUT

