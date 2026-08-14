<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.3.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.3.8** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): Multiple `run:` blocks in release.yml directly interpolate `${{ ... }}` expressions into shell commands without routing through `env:` variables first. This allows an attacker who can trigger `workflow_dispatch` to inject arbitrary shell commands.

Affected expressions and steps:
- 'Compute next version': `explicit="${{ inputs.version }}"` (line 46) and `case "${{ inputs.bump }}"` (line 63) — `inputs.version` and `inputs.bump` are workflow_dispatch inputs directly embedded in shell.
- 'Detect resume state': `v="${{ steps.ver.outputs.version }}"` (line 81) — step output interpolated directly.
- 'Bump version in tracked files': `v="${{ steps.ver.outputs.version }}"` — same pattern.
- 'Build CHANGELOG entry': `v="${{ steps.ver.outputs.version }}"` — same pattern.
- 'Open release PR': `v="${{ steps.ver.outputs.version }}"`, `br="${{ steps.ver.outputs.branch }}"`, `"${{ github.actor }}"`, `"${{ steps.ver.outputs.previous }}"`, `"${{ inputs.bump }}"`, `"${{ inputs.dry_run }}"` — multiple untrusted values directly in shell.
- 'Auto-merge release PR': `gh pr merge "${{ steps.pr.outputs.url }}"` — step output directly in shell.
- 'Wait for PR to merge': `gh pr view "${{ steps.pr.outputs.url }}"` — step output directly in shell.
- 'Tag and publish release': `v="${{ steps.ver.outputs.version }}"`, `maj="${{ steps.ver.outputs.major }}"` — step outputs directly in shell.

All of these should be moved into `env:` variables and referenced as `"$VAR"` in the shell script.

Locations:

- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:63`
- `.github/workflows/release.yml:81`
- `.github/workflows/release.yml:107`
- `.github/workflows/release.yml:122`
- `.github/workflows/release.yml:133`
- `.github/workflows/release.yml:143`
- `.github/workflows/release.yml:155`
- `.github/workflows/release.yml:163`
- `.github/workflows/release.yml:172`

### script-injection (severity: high)

Rule (b): In the 'Run Agent Guard' step of action.yml, the env var `AGENT_GUARD_PATHS` (sourced from `${{ inputs.paths }}`) is expanded unquoted in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted expansion allows a calling workflow to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) via the `paths` input. The comment acknowledges the unquoted expansion is intentional for word-splitting, but this does not prevent command injection.

Locations:

- `action.yml:90`

### unpinned-uses (severity: high)

Multiple workflow files reference external actions using mutable version tags instead of pinned 40-character commit SHAs. A tag can be moved by the action author (or a compromised account) to point to malicious code at any time.

- ci.yml: `actions/checkout@v5` (appears twice — secret-guard and test jobs)
- codex-review.yml: `actions/checkout@v5`, `openai/codex-action@v1`, `actions/github-script@v7`
- plugin-validation.yml: `actions/checkout@v5`
- release.yml: `actions/checkout@v5`

All should be pinned to full SHA digests, e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4`.

Locations:

- `.github/workflows/ci.yml:14`
- `.github/workflows/ci.yml:22`
- `.github/workflows/codex-review.yml:29`
- `.github/workflows/codex-review.yml:42`
- `.github/workflows/codex-review.yml:57`
- `.github/workflows/plugin-validation.yml:13`
- `.github/workflows/release.yml:38`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses

**Notes:**

Fixed all three findings:

1. script-injection in release.yml: Moved all ${{ inputs.* }}, ${{ steps.*.outputs.* }}, ${{ github.actor }}, and ${{ inputs.dry_run }} expressions from run: shell blocks into env: blocks. Each step now uses named env vars (INPUT_VERSION, INPUT_BUMP, VER_VERSION, VER_BRANCH, VER_PREVIOUS, GITHUB_ACTOR, INPUT_DRY_RUN, VER_MAJOR, PR_URL) referenced as $VAR_NAME in the shell. if: conditions retain ${{ }} as they are evaluated by GitHub Actions, not the shell.

2. script-injection in action.yml: Replaced unquoted $AGENT_GUARD_PATHS expansion with IFS=' ' read -ra path_args <<< "${AGENT_GUARD_PATHS}" and "${path_args[@]}" to safely split space-separated paths into quoted array elements, preventing shell metacharacter injection.

3. unpinned-uses: Pinned all mutable action tags to full 40-char SHAs with tag comments: actions/checkout@v5 → fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09 (5 occurrences across ci.yml, codex-review.yml, plugin-validation.yml, release.yml); openai/codex-action@v1 → 52fe01ec70a42f454c9d2ebd47598f9fd6893d56; actions/github-script@v7 → f28e40c7f34bde8b3046d885e986cb6290c5673b.

