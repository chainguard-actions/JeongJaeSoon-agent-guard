<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.3.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.3.5** was hardened automatically. 2 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files reference GitHub Actions using mutable version tags instead of pinned full-length SHA commit hashes. This exposes the workflow to supply-chain attacks if the upstream action tag is moved or compromised.

Failing references:
- .github/workflows/ci.yml: `actions/checkout@v5` (lines 18, 30)
- .github/workflows/codex-review.yml: `actions/checkout@v5` (line 22), `openai/codex-action@v1` (line 38), `actions/github-script@v7` (line 72)
- .github/workflows/plugin-validation.yml: `actions/checkout@v5` (line 18)
- .github/workflows/release.yml: `actions/checkout@v5` (line 38)

Locations:

- `.github/workflows/ci.yml:18`
- `.github/workflows/codex-review.yml:22`
- `.github/workflows/codex-review.yml:38`
- `.github/workflows/codex-review.yml:72`
- `.github/workflows/plugin-validation.yml:18`
- `.github/workflows/release.yml:38`

### script-injection (severity: high)

Multiple `run:` blocks in release.yml directly interpolate GitHub Actions expressions (${{ ... }}) into shell commands (sub-rule a). This allows template substitution to inject arbitrary shell metacharacters before the shell ever parses the command.

Affected steps and offending expressions:

1. "Compute next version" step: `explicit="${{ inputs.version }}"` and `case "${{ inputs.bump }}" in` — user-supplied workflow_dispatch inputs are interpolated directly into shell variable assignments and a case statement.

2. "Detect resume state" step: `v="${{ steps.ver.outputs.version }}"`

3. "Bump version in tracked files" step: `v="${{ steps.ver.outputs.version }}"`

4. "Build CHANGELOG entry" step: `v="${{ steps.ver.outputs.version }}"`

5. "Open release PR" step: `v="${{ steps.ver.outputs.version }}"`, `br="${{ steps.ver.outputs.branch }}"`, `${{ github.actor }}`, `${{ steps.ver.outputs.previous }}`, `${{ inputs.bump }}`, `${{ inputs.dry_run }}`

6. "Auto-merge release PR" step: `gh pr merge "${{ steps.pr.outputs.url }}"`

7. "Wait for PR to merge" step: `gh pr view "${{ steps.pr.outputs.url }}"`

8. "Tag and publish release" step: `v="${{ steps.ver.outputs.version }}"`, `maj="${{ steps.ver.outputs.major }}"`

All values should be passed via `env:` variables and referenced as shell variables (e.g., `"$VERSION"`) rather than interpolated directly.

Locations:

- `.github/workflows/release.yml:44`
- `.github/workflows/release.yml:57`
- `.github/workflows/release.yml:68`
- `.github/workflows/release.yml:100`
- `.github/workflows/release.yml:115`
- `.github/workflows/release.yml:128`
- `.github/workflows/release.yml:148`
- `.github/workflows/release.yml:157`
- `.github/workflows/release.yml:168`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

Fixed all unpinned action references by pinning to full commit SHAs: actions/checkout@v5→fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09 (ci.yml ×2, codex-review.yml, plugin-validation.yml, release.yml), openai/codex-action@v1→52fe01ec70a42f454c9d2ebd47598f9fd6893d56 (codex-review.yml), actions/github-script@v7→f28e40c7f34bde8b3046d885e986cb6290c5673b (codex-review.yml). Fixed all script injection issues in release.yml by moving every ${{ }} expression from run: shell strings into env: blocks and referencing them as plain shell variables ($VAR_NAME). All 8 affected steps now use env: variables: INPUT_VERSION/INPUT_BUMP (Compute next version), VER_VERSION (Detect resume state, Bump version, Build CHANGELOG), VER_VERSION/VER_BRANCH/VER_PREVIOUS/GITHUB_ACTOR/INPUT_BUMP/INPUT_DRY_RUN (Open release PR), PR_URL (Auto-merge and Wait for PR), VER_VERSION/VER_MAJOR (Tag and publish).

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed the unquoted expansion of $AGENT_GUARD_PATHS in the 'Run Agent Guard' step. Replaced the unquoted `$AGENT_GUARD_PATHS` expansion with a bash array approach: `IFS=' ' read -ra path_args <<< "$AGENT_GUARD_PATHS"` followed by `"${path_args[@]}"`. This safely splits the space-separated paths into individual array elements without performing glob expansion or interpreting shell metacharacters, while preserving the intended functionality of accepting multiple paths.

### Iteration 3

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in .github/workflows/release.yml (lines 73-75). The 'Compute next version' step now sanitizes all user-controlled values ($v, $MA, $cur) using `printf '%s' "$var" | tr -d '\n\r'` before writing them to $GITHUB_OUTPUT. The sanitized values are stored in safe_v, safe_MA, and safe_cur variables, which are then used in the four echo statements that write to $GITHUB_OUTPUT. Although a regex validation already guards against malformed input, the required sanitization pipeline is now applied before every write to the special environment file.

