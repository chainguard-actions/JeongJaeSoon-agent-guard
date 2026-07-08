<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.9.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard/v1.9.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): Multiple run: blocks in release.yml directly interpolate ${{ ... }} expressions inside shell commands. This allows YAML template substitution before the shell ever sees the value, enabling command injection. Offending lines include: `explicit="${{ inputs.version }}"` (line 46), `case "${{ inputs.bump }}" in` (line 63), `v="${{ steps.ver.outputs.version }}"` (lines 81, 113, 127, 140), `br="${{ steps.ver.outputs.branch }}"` (line 141), `"${{ github.actor }}"` (line 151), `"${{ steps.ver.outputs.previous }}"` (line 152), `"${{ inputs.bump }}"` (line 153), `"${{ inputs.dry_run }}"` (line 154), `"${{ steps.pr.outputs.url }}"` (lines 163, 170), `maj="${{ steps.ver.outputs.major }}"` (line 179). All of these should be moved to env: blocks and referenced as shell variables.

Locations:

- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:63`
- `.github/workflows/release.yml:81`
- `.github/workflows/release.yml:113`
- `.github/workflows/release.yml:127`
- `.github/workflows/release.yml:140`
- `.github/workflows/release.yml:163`
- `.github/workflows/release.yml:170`
- `.github/workflows/release.yml:178`

### script-injection (severity: high)

Rule (b): In action.yml, the 'Run Agent Guard' step expands $AGENT_GUARD_PATHS (sourced from inputs.paths, a user-controlled value) without double-quoting: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted expansion allows the shell to parse metacharacters (;, |, &, $(...), etc.) from the value, enabling command injection. The shellcheck disable comment acknowledges the word-splitting but does not address the injection risk.

Locations:

- `action.yml:97`

### github-env-injection (severity: high)

In the 'Compute next version' step of release.yml, values derived from user-controlled inputs (${{ inputs.version }} and ${{ inputs.bump }}) are written to $GITHUB_OUTPUT without the required sanitization step (printf '%s' ... | tr -d '\n\r'). The variables $v, $MA, $cur are all derived from inputs.version or inputs.bump and written directly: `echo "version=$v" >> "$GITHUB_OUTPUT"`, `echo "major=v${MA}" >> "$GITHUB_OUTPUT"`, `echo "branch=release/v${v}" >> "$GITHUB_OUTPUT"`, `echo "previous=${cur}" >> "$GITHUB_OUTPUT"`. A newline in inputs.version could inject arbitrary key=value pairs into GITHUB_OUTPUT.

Locations:

- `.github/workflows/release.yml:70`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all three findings:
1. release.yml script-injection: Moved all ${{ inputs.version }}, ${{ inputs.bump }}, ${{ steps.ver.outputs.* }}, ${{ github.actor }}, ${{ inputs.dry_run }}, ${{ steps.pr.outputs.url }}, and ${{ steps.ver.outputs.major }} expressions out of run: shell blocks and into env: blocks. Each step now references plain environment variables ($INPUT_VERSION, $INPUT_BUMP, $VER_VERSION, $VER_BRANCH, $VER_MAJOR, $GITHUB_ACTOR_NAME, $VER_PREVIOUS, $INPUT_DRY_RUN, $PR_URL) in the shell script.
2. release.yml github-env-injection: In the 'Compute next version' step, values derived from user-controlled inputs ($v, $MA, $cur) are now sanitized with `printf '%s' ... | tr -d '\n\r'` before being written to $GITHUB_OUTPUT, preventing newline injection attacks.
3. action.yml script-injection: Replaced the unquoted `$AGENT_GUARD_PATHS` expansion (which allowed shell metacharacter injection) with `IFS=' ' read -ra path_args <<< "$AGENT_GUARD_PATHS"` followed by `"${path_args[@]}"`, ensuring each path element is properly quoted and shell metacharacters cannot be injected.

