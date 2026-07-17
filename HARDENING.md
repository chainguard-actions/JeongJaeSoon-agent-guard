<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.7.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.7.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): In the 'Run Agent Guard' step, the env var `AGENT_GUARD_PATHS` is sourced from `inputs.paths` (user-controlled) and used UNQUOTED in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted shell expansion allows a caller to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) via the `paths` input, enabling command injection. The comment `# shellcheck disable=SC2086` acknowledges the unquoted expansion but does not mitigate the security risk. Fix: use `"$AGENT_GUARD_PATHS"` (quoted) or split the value safely.

Locations:

- `action.yml:91`

### script-injection (severity: high)

Rule (a): Multiple `${{ }}` expressions are interpolated directly inside `run:` shell command strings in release.yml. GitHub Actions expands these template expressions before the shell parses the script, so any value containing shell metacharacters is injected verbatim into the shell. Affected expressions and steps:
- 'Compute next version': `explicit="${{ inputs.version }}"` and `case "${{ inputs.bump }}"`
- 'Detect resume state': `v="${{ steps.ver.outputs.version }}"`
- 'Bump version in tracked files': `v="${{ steps.ver.outputs.version }}"`
- 'Build CHANGELOG entry': `v="${{ steps.ver.outputs.version }}"`
- 'Open release PR': `v="${{ steps.ver.outputs.version }}"`, `br="${{ steps.ver.outputs.branch }}"`, `"${{ github.actor }}"`, `"${{ steps.ver.outputs.previous }}"`, `"${{ inputs.bump }}"`, `"${{ inputs.dry_run }}"`
- 'Auto-merge release PR': `gh pr merge "${{ steps.pr.outputs.url }}"`
- 'Wait for PR to merge': `gh pr view "${{ steps.pr.outputs.url }}"`
- 'Tag and publish release': `v="${{ steps.ver.outputs.version }}"`, `maj="${{ steps.ver.outputs.major }}"`
Fix: move all values into `env:` variables and reference them as `"$VAR"` in the shell script.

Locations:

- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:60`
- `.github/workflows/release.yml:73`
- `.github/workflows/release.yml:100`
- `.github/workflows/release.yml:120`
- `.github/workflows/release.yml:131`
- `.github/workflows/release.yml:132`
- `.github/workflows/release.yml:148`
- `.github/workflows/release.yml:149`
- `.github/workflows/release.yml:150`
- `.github/workflows/release.yml:151`
- `.github/workflows/release.yml:157`
- `.github/workflows/release.yml:165`
- `.github/workflows/release.yml:178`
- `.github/workflows/release.yml:179`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings:

1. action.yml (line 91): Replaced unquoted `$AGENT_GUARD_PATHS` expansion with a safe bash array approach: `IFS=' ' read -ra _paths <<< "$AGENT_GUARD_PATHS"` then `"${_paths[@]}"`. This prevents shell metacharacter injection via the `paths` input while still supporting space-separated multiple paths.

2. release.yml (multiple lines): Moved all `${{ }}` expressions out of `run:` shell scripts and into `env:` blocks for all affected steps: 'Compute next version' (inputs.version, inputs.bump), 'Detect resume state' (steps.ver.outputs.version), 'Bump version in tracked files' (steps.ver.outputs.version), 'Build CHANGELOG entry' (steps.ver.outputs.version), 'Open release PR' (steps.ver.outputs.version, steps.ver.outputs.branch, github.actor, steps.ver.outputs.previous, inputs.bump, inputs.dry_run), 'Auto-merge release PR' (steps.pr.outputs.url), 'Wait for PR to merge' (steps.pr.outputs.url), 'Tag and publish release' (steps.ver.outputs.version, steps.ver.outputs.major). All shell scripts now reference plain environment variables instead of template expressions.

