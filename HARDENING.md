<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.3.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.3.6** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple workflow files reference GitHub Actions using mutable tag-based refs instead of pinned full 40-character SHA commits. This exposes the workflow to supply-chain attacks if the referenced action's tag is moved or compromised.

Failing references:
- ci.yml: `actions/checkout@v5` (two occurrences)
- codex-review.yml: `actions/checkout@v5`, `openai/codex-action@v1`, `actions/github-script@v7`
- plugin-validation.yml: `actions/checkout@v5`
- release.yml: `actions/checkout@v5`

Locations:

- `.github/workflows/ci.yml:16`
- `.github/workflows/ci.yml:24`
- `.github/workflows/codex-review.yml:20`
- `.github/workflows/codex-review.yml:37`
- `.github/workflows/codex-review.yml:73`
- `.github/workflows/plugin-validation.yml:13`
- `.github/workflows/release.yml:33`

### script-injection (severity: high)

Multiple `run:` blocks directly interpolate GitHub Actions expressions (`${{ ... }}`) into shell commands, enabling script injection.

**action.yml — rule (b): unquoted env var expansion**
In the "Run Agent Guard" step, `AGENT_GUARD_PATHS` is sourced from `${{ inputs.paths }}` and then expanded unquoted in the shell command:
```
"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS
```
An attacker-controlled `paths` input containing shell metacharacters (`;`, `|`, `$(...)`, etc.) can break out of the intended argument context.

**release.yml — rule (a): direct expression interpolation in run: blocks**
Multiple steps interpolate expressions directly into shell:
- `explicit="${{ inputs.version }}"` — Compute next version step
- `case "${{ inputs.bump }}" in` — Compute next version step
- `v="${{ steps.ver.outputs.version }}"` — multiple steps
- `br="${{ steps.ver.outputs.branch }}"` — Open release PR step
- `"${{ github.actor }}"` — Open release PR step (printf argument)
- `gh pr merge "${{ steps.pr.outputs.url }}"` — Auto-merge step
- `gh pr view "${{ steps.pr.outputs.url }}"` — Wait for PR step
- `v="${{ steps.ver.outputs.major }}"` — Tag and publish step

**codex-review.yml — rule (a): direct expression interpolation in run: block**
- `"+refs/pull/$PR_NUMBER/head"` uses `$PR_NUMBER` from env (safe), but the `ref:` field uses `${{ github.event.pull_request.number }}` directly in a `with:` block (not a run: block). However, the `run:` block in "Fetch PR refs" uses env vars safely.

Locations:

- `action.yml:96`
- `.github/workflows/release.yml:42`
- `.github/workflows/release.yml:55`
- `.github/workflows/release.yml:69`
- `.github/workflows/release.yml:78`
- `.github/workflows/release.yml:113`
- `.github/workflows/release.yml:116`
- `.github/workflows/release.yml:117`
- `.github/workflows/release.yml:118`
- `.github/workflows/release.yml:119`
- `.github/workflows/release.yml:126`
- `.github/workflows/release.yml:135`
- `.github/workflows/release.yml:144`
- `.github/workflows/release.yml:152`
- `.github/workflows/release.yml:153`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

Fixed all 7 unpinned action references by pinning to full SHA commits (actions/checkout@fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09, openai/codex-action@52fe01ec70a42f454c9d2ebd47598f9fd6893d56, actions/github-script@f28e40c7f34bde8b3046d885e986cb6290c5673b). Fixed script injection in action.yml by replacing unquoted $AGENT_GUARD_PATHS expansion with a safe IFS-split array approach. Fixed all script injection in release.yml by moving every ${{ }} expression from run: blocks into env: blocks and referencing them as plain shell environment variables ($INPUT_VERSION, $INPUT_BUMP, $VER_VERSION, $VER_BRANCH, $VER_PREVIOUS, $GITHUB_ACTOR, $PR_URL, $VER_MAJOR, etc.).

