<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.10.0** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step of action.yml, the env var `$AGENT_GUARD_PATHS` (sourced from `inputs.paths`, a user-controlled value via `AGENT_GUARD_PATHS: ${{ inputs.paths }}`) is expanded unquoted in the run block: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker-controlled `paths` input containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) will be interpreted by the shell before the command runs, enabling command injection. The shellcheck-disable comment acknowledges the word-splitting is intentional, but this does not mitigate the injection risk.

Locations:

- `action.yml:97`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml. The original code expanded `$AGENT_GUARD_PATHS` unquoted (`-- $AGENT_GUARD_PATHS`), allowing attacker-controlled shell metacharacters in the `paths` input to be interpreted by the shell. The fix uses `IFS=' ' read -ra path_args <<< "$AGENT_GUARD_PATHS"` to safely split the space-separated paths into a bash array, then passes them as `"${path_args[@]}"`. This preserves the intended word-splitting behavior (multiple space-separated paths) while preventing shell metacharacter injection, since the variable is always quoted when expanded.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all ${{ }} expressions in run: blocks by moving them to env: blocks in release.yml:
1. 'Compute next version': INPUT_VERSION=${{ inputs.version }}, INPUT_BUMP=${{ inputs.bump }}; added safe_v/safe_ma/safe_cur sanitization (printf | tr -d '\n\r') before all three GITHUB_OUTPUT writes.
2. 'Detect resume state': VER_VERSION=${{ steps.ver.outputs.version }}.
3. 'Bump version in tracked files': VER_VERSION=${{ steps.ver.outputs.version }}.
4. 'Build CHANGELOG entry': VER_VERSION=${{ steps.ver.outputs.version }}.
5. 'Open release PR': VER_VERSION, VER_BRANCH, GITHUB_ACTOR, VER_PREVIOUS, INPUT_BUMP, INPUT_DRY_RUN all moved to env:.
6. 'Auto-merge release PR': PR_URL=${{ steps.pr.outputs.url }}.
7. 'Wait for PR to merge': PR_URL=${{ steps.pr.outputs.url }}.
8. 'Tag and publish release': VER_VERSION=${{ steps.ver.outputs.version }}, VER_MAJOR=${{ steps.ver.outputs.major }}.

