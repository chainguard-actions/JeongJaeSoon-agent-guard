<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.10.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **JeongJaeSoon--agent-guard/v1.10.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple ${{ }} expressions are directly interpolated inside run: shell command strings in release.yml. In the 'Compute next version' step: `explicit="${{ inputs.version }}"` (line 46) and `case "${{ inputs.bump }}" in` (line 63). In the 'Detect resume state' step: `v="${{ steps.ver.outputs.version }}"`. In the 'Bump version in tracked files' step: `v="${{ steps.ver.outputs.version }}"`. In the 'Build CHANGELOG entry' step: `v="${{ steps.ver.outputs.version }}"`. In the 'Open release PR' step: `v="${{ steps.ver.outputs.version }}"`, `br="${{ steps.ver.outputs.branch }}"`, `${{ github.actor }}`, `${{ steps.ver.outputs.previous }}`, `${{ inputs.bump }}`, `${{ inputs.dry_run }}`. In the 'Auto-merge release PR' step: `${{ steps.pr.outputs.url }}`. In the 'Wait for PR to merge' step: `${{ steps.pr.outputs.url }}`. In the 'Tag and publish release' step: `v="${{ steps.ver.outputs.version }}"` and `maj="${{ steps.ver.outputs.major }}"`. All of these allow workflow-controlled or attacker-controlled values to be injected into the shell before quoting occurs.

Locations:

- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:63`
- `.github/workflows/release.yml:80`
- `.github/workflows/release.yml:120`
- `.github/workflows/release.yml:135`
- `.github/workflows/release.yml:150`
- `.github/workflows/release.yml:175`
- `.github/workflows/release.yml:185`
- `.github/workflows/release.yml:200`

### script-injection (severity: high)

Sub-rule (b): In the 'Run Agent Guard' step of action.yml (line 99), the env var $AGENT_GUARD_PATHS (sourced from ${{ inputs.paths }}) is expanded unquoted in the run: block: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The `# shellcheck disable=SC2086` comment acknowledges the unquoted expansion. An attacker-controlled `inputs.paths` value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, whitespace, glob chars) can break out of the intended argument list and inject arbitrary shell commands.

Locations:

- `action.yml:99`

### github-env-injection (severity: high)

In the 'Compute next version' step of release.yml, the variable `v` is derived directly from `${{ inputs.version }}` (interpolated inline as `explicit="${{ inputs.version }}"` then `v="$explicit"`) and then written to $GITHUB_OUTPUT without sanitization: `echo "version=$v" >> "$GITHUB_OUTPUT"`, `echo "major=v${MA}" >> "$GITHUB_OUTPUT"`, `echo "branch=release/v${v}" >> "$GITHUB_OUTPUT"`, and `echo "previous=${cur}" >> "$GITHUB_OUTPUT"`. No `printf '%s' ... | tr -d '\n\r'` sanitization step is applied before the writes. A newline embedded in inputs.version could inject arbitrary key=value pairs into GITHUB_OUTPUT, potentially poisoning downstream steps that consume these outputs.

Locations:

- `.github/workflows/release.yml:70`
- `.github/workflows/release.yml:71`
- `.github/workflows/release.yml:72`
- `.github/workflows/release.yml:73`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all three findings: (1) In release.yml, moved all ${{ }} expressions from run: shell strings into env: blocks across all steps (Compute next version, Detect resume state, Bump version in tracked files, Build CHANGELOG entry, Open release PR, Auto-merge release PR, Wait for PR to merge, Tag and publish release). (2) In release.yml Compute next version step, sanitized all GITHUB_OUTPUT writes using 'printf "%s" "$var" | tr -d "\n\r"' before writing version, major, branch, and previous outputs. (3) In action.yml Run Agent Guard step, replaced the unquoted $AGENT_GUARD_PATHS expansion (with shellcheck disable comment) with a safe 'IFS=" " read -ra path_args <<< "$AGENT_GUARD_PATHS"' array split, then passed "${path_args[@]}" as properly quoted array elements.

