<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.0.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.0.1** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple run: blocks in release.yml directly interpolate ${{ }} expressions inside shell scripts. Affected steps: (1) 'Compute next version' — `case "${{ inputs.bump }}" in` interpolates a workflow_dispatch input directly into a shell case statement; (2) 'Detect resume state' — `v="${{ steps.ver.outputs.version }}"`; (3) 'Bump version in tracked files' — `v="${{ steps.ver.outputs.version }}"`; (4) 'Build CHANGELOG entry' — `v="${{ steps.ver.outputs.version }}"`; (5) 'Open release PR' — `v="${{ steps.ver.outputs.version }}"`, `br="${{ steps.ver.outputs.branch }}"`, and `${{ github.actor }}`, `${{ steps.ver.outputs.previous }}`, `${{ inputs.bump }}`, `${{ inputs.dry_run }}` inside a printf call; (6) 'Auto-merge release PR' — `gh pr merge "${{ steps.pr.outputs.url }}"`; (7) 'Wait for PR to merge' — `gh pr view "${{ steps.pr.outputs.url }}"`; (8) 'Tag and publish release' — `v="${{ steps.ver.outputs.version }}"` and `maj="${{ steps.ver.outputs.major }}"`. All of these should be moved to env: variables and referenced as "$VAR" in the shell script body.

Locations:

- `.github/workflows/release.yml:68`
- `.github/workflows/release.yml:82`
- `.github/workflows/release.yml:120`
- `.github/workflows/release.yml:141`
- `.github/workflows/release.yml:153`
- `.github/workflows/release.yml:175`
- `.github/workflows/release.yml:183`
- `.github/workflows/release.yml:193`

### script-injection (severity: high)

Sub-rule (b): In action.yml, the 'Run Agent Guard' step uses $AGENT_GUARD_PATHS unquoted in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The variable AGENT_GUARD_PATHS is set from `${{ inputs.paths }}` (a user-controlled composite action input). Without double-quoting, shell metacharacters in the input value (semicolons, pipes, ampersands, command substitution, glob characters, whitespace) can be interpreted by the shell, enabling command injection. The shellcheck disable comment acknowledges the unquoted expansion but does not mitigate the security risk.

Locations:

- `action.yml:92`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings:

1. `.github/workflows/release.yml` (8 locations): Moved all `${{ }}` expressions out of `run:` shell script bodies and into `env:` blocks. Affected steps: 'Compute next version' (added INPUT_BUMP env var, replaced `case "${{ inputs.bump }}"`), 'Detect resume state' (added VER_VERSION), 'Bump version in tracked files' (added VER_VERSION), 'Build CHANGELOG entry' (added VER_VERSION), 'Open release PR' (added VER_VERSION, VER_BRANCH, GITHUB_ACTOR_NAME, VER_PREVIOUS, INPUT_BUMP, INPUT_DRY_RUN for all 6 inline expressions), 'Auto-merge release PR' (added PR_URL), 'Wait for PR to merge' (added PR_URL), 'Tag and publish release' (added VER_VERSION, VER_MAJOR).

2. `action.yml` (line 92): Replaced unquoted `$AGENT_GUARD_PATHS` shell expansion with `read -ra path_args <<< "$AGENT_GUARD_PATHS"` followed by `"${path_args[@]}"`. This splits the space-separated paths into a bash array and passes each element as a properly-quoted separate argument, preventing shell metacharacter injection from user-controlled input while preserving the multi-path functionality.

