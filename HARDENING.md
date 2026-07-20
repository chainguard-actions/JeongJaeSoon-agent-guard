<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.8.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.8.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple `run:` blocks in release.yml directly interpolate GitHub Actions expressions inside shell commands (sub-rule a). This allows an attacker with control over workflow inputs or step outputs to inject arbitrary shell commands.

Affected lines in 'Compute next version' step:
- Line 46: `explicit="${{ inputs.version }}"`
- Line 63: `case "${{ inputs.bump }}" in`

Affected lines in 'Detect resume state' step:
- Line 75: `v="${{ steps.ver.outputs.version }}"`

Affected lines in 'Bump version in tracked files' step:
- Line 117: `v="${{ steps.ver.outputs.version }}"`

Affected lines in 'Build CHANGELOG entry' step:
- Line 135: `v="${{ steps.ver.outputs.version }}"`

Affected lines in 'Open release PR' step:
- Line 152: `v="${{ steps.ver.outputs.version }}"`
- Line 153: `br="${{ steps.ver.outputs.branch }}"`
- Line 163: `"${{ github.actor }}"`
- Line 164: `"${{ steps.ver.outputs.previous }}"`
- Line 165: `"${{ inputs.bump }}"`
- Line 166: `"${{ inputs.dry_run }}"`

Affected lines in 'Auto-merge release PR' step:
- Line 178: `gh pr merge "${{ steps.pr.outputs.url }}" --squash --delete-branch --auto`

Affected lines in 'Wait for PR to merge' step:
- Line 187: `state=$(gh pr view "${{ steps.pr.outputs.url }}" --json state -q .state)`

Affected lines in 'Tag and publish release' step:
- Line 198: `v="${{ steps.ver.outputs.version }}"`
- Line 199: `maj="${{ steps.ver.outputs.major }}"`

All these values should be passed via `env:` variables and then referenced as `"$VAR"` inside the shell script.

Locations:

- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:63`
- `.github/workflows/release.yml:75`
- `.github/workflows/release.yml:117`
- `.github/workflows/release.yml:135`
- `.github/workflows/release.yml:152`
- `.github/workflows/release.yml:153`
- `.github/workflows/release.yml:163`
- `.github/workflows/release.yml:165`
- `.github/workflows/release.yml:178`
- `.github/workflows/release.yml:187`
- `.github/workflows/release.yml:198`
- `.github/workflows/release.yml:199`

### script-injection (severity: high)

The 'Run Agent Guard' step in action.yml uses `$AGENT_GUARD_PATHS` unquoted in the shell command (sub-rule b). `AGENT_GUARD_PATHS` is sourced from `inputs.paths` via the `env:` block. The script intentionally disables shellcheck (SC2086) to allow word-splitting, but this also allows shell metacharacter injection (`;`, `|`, `&`, `$(...)`, etc.) from attacker-controlled input. The offending line is: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`

Locations:

- `action.yml:97`

### github-env-injection (severity: high)

The 'Compute next version' step in release.yml writes values derived from `${{ inputs.version }}` (directly interpolated into the run block) to `$GITHUB_OUTPUT` without sanitization. The variables `$v`, `$MA`, and the branch string are all tainted by the user-supplied `inputs.version` value. Without `printf '%s' ... | tr -d '\n\r'` sanitization before each write, a newline in the input could inject additional key=value pairs into GITHUB_OUTPUT, poisoning downstream steps.

Affected writes:
- `echo "version=$v" >> "$GITHUB_OUTPUT"`
- `echo "major=v${MA}" >> "$GITHUB_OUTPUT"`
- `echo "branch=release/v${v}" >> "$GITHUB_OUTPUT"`

Locations:

- `.github/workflows/release.yml:64`
- `.github/workflows/release.yml:65`
- `.github/workflows/release.yml:66`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all script-injection findings in release.yml by moving every ${{ }} expression from run: blocks into env: blocks and referencing them as plain shell variables. Fixed github-env-injection by sanitizing GITHUB_OUTPUT writes in the 'Compute next version' step using printf + tr -d '\n\r'. Fixed script-injection in action.yml by replacing the unquoted $AGENT_GUARD_PATHS word-split with a bash array (IFS=' ' read -ra path_args) to prevent shell metacharacter injection while preserving the intended space-separated path splitting behavior.

