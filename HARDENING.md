<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.10.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard/v1.10.1** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `AGENT_GUARD_PATHS` holds the value of `${{ inputs.paths }}` (a workflow-controllable input) and is expanded **unquoted** in the run script: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted shell expansion allows an attacker-supplied `inputs.paths` value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) to be interpreted by the shell, enabling command injection. The comment `# shellcheck disable=SC2086` acknowledges the unquoted expansion but does not mitigate the security risk. Fix: use `"$AGENT_GUARD_PATHS"` or, if word-splitting is intentional, sanitize the value before use.

Locations:

- `action.yml:100`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted `$AGENT_GUARD_PATHS` expansion in the 'Run Agent Guard' step. Replaced the unquoted `$AGENT_GUARD_PATHS` (with `# shellcheck disable=SC2086`) with a safe bash array: `read -ra _paths <<< "$AGENT_GUARD_PATHS"` followed by `"${_paths[@]}"`. This preserves the intended word-splitting on whitespace for space-separated paths while preventing shell metacharacter injection (`;`, `|`, `&`, `$(...)`, etc.) from being interpreted by the shell.

### Iteration 2

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 8 script-injection findings and 1 github-env-injection finding in .github/workflows/release.yml:

1. 'Compute next version' step: Moved ${{ inputs.version }} and ${{ inputs.bump }} into env: block as INPUT_VERSION and INPUT_BUMP. Added sanitization (printf '%s' | tr -d '\n\r') for all values written to $GITHUB_OUTPUT.

2. 'Detect resume state' step: Moved ${{ steps.ver.outputs.version }} into env: block as VER_VERSION.

3. 'Bump version in tracked files' step: Moved ${{ steps.ver.outputs.version }} into env: block as VER_VERSION.

4. 'Build CHANGELOG entry' step: Moved ${{ steps.ver.outputs.version }} into env: block as VER_VERSION.

5. 'Open release PR' step: Moved ${{ steps.ver.outputs.version }}, ${{ steps.ver.outputs.branch }}, ${{ github.actor }}, ${{ steps.ver.outputs.previous }}, ${{ inputs.bump }}, and ${{ inputs.dry_run }} into env: block as VER_VERSION, VER_BRANCH, GITHUB_ACTOR, VER_PREVIOUS, INPUT_BUMP, and INPUT_DRY_RUN respectively.

6. 'Auto-merge release PR' step: Moved ${{ steps.pr.outputs.url }} into env: block as PR_URL.

7. 'Wait for PR to merge' step: Moved ${{ steps.pr.outputs.url }} into env: block as PR_URL.

8. 'Tag and publish release' step: Moved ${{ steps.ver.outputs.version }} and ${{ steps.ver.outputs.major }} into env: block as VER_VERSION and VER_MAJOR.

All ${{ }} expressions in run: blocks have been eliminated. The github-env-injection finding was addressed by sanitizing all values derived from user inputs before writing to $GITHUB_OUTPUT using printf '%s' ... | tr -d '\n\r'.

