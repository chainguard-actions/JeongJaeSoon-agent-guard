<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.7.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.7.1** was hardened automatically. 10 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Compute next version' run: block directly interpolates ${{ inputs.version }} and ${{ inputs.bump }} into the shell script. These workflow_dispatch inputs are attacker-controllable and are embedded verbatim before the shell parses the script, enabling command injection. Offending lines: `explicit="${{ inputs.version }}"` and `case "${{ inputs.bump }}" in`.

Locations:

- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:63`

### script-injection (severity: high)

Rule (a): The 'Detect resume state' run: block directly interpolates ${{ steps.ver.outputs.version }} into the shell script. steps.*.outputs.* is a workflow-controllable context and must not appear directly in a run: block. Offending line: `v="${{ steps.ver.outputs.version }}"`.

Locations:

- `.github/workflows/release.yml:81`

### script-injection (severity: high)

Rule (a): The 'Bump version in tracked files' run: block directly interpolates ${{ steps.ver.outputs.version }} into the shell script. steps.*.outputs.* is a workflow-controllable context and must not appear directly in a run: block. Offending line: `v="${{ steps.ver.outputs.version }}"`.

Locations:

- `.github/workflows/release.yml:120`

### script-injection (severity: high)

Rule (a): The 'Build CHANGELOG entry' run: block directly interpolates ${{ steps.ver.outputs.version }} into the shell script. steps.*.outputs.* is a workflow-controllable context and must not appear directly in a run: block. Offending line: `v="${{ steps.ver.outputs.version }}"`.

Locations:

- `.github/workflows/release.yml:133`

### script-injection (severity: high)

Rule (a): The 'Open release PR' run: block directly interpolates multiple expressions into the shell script: ${{ steps.ver.outputs.version }}, ${{ steps.ver.outputs.branch }}, ${{ github.actor }}, ${{ steps.ver.outputs.previous }}, ${{ inputs.bump }}, and ${{ inputs.dry_run }}. All of these are workflow-controllable contexts embedded verbatim before shell parsing, enabling command injection.

Locations:

- `.github/workflows/release.yml:148`
- `.github/workflows/release.yml:149`
- `.github/workflows/release.yml:159`
- `.github/workflows/release.yml:160`
- `.github/workflows/release.yml:161`
- `.github/workflows/release.yml:162`

### script-injection (severity: high)

Rule (a): The 'Auto-merge release PR' run: block directly interpolates ${{ steps.pr.outputs.url }} into the shell command: `gh pr merge "${{ steps.pr.outputs.url }}" --squash --delete-branch --auto`. steps.*.outputs.* is a workflow-controllable context.

Locations:

- `.github/workflows/release.yml:172`

### script-injection (severity: high)

Rule (a): The 'Wait for PR to merge' run: block directly interpolates ${{ steps.pr.outputs.url }} into the shell command: `gh pr view "${{ steps.pr.outputs.url }}" --json state -q .state`. steps.*.outputs.* is a workflow-controllable context.

Locations:

- `.github/workflows/release.yml:182`

### script-injection (severity: high)

Rule (a): The 'Tag and publish release' run: block directly interpolates ${{ steps.ver.outputs.version }} and ${{ steps.ver.outputs.major }} into the shell script. steps.*.outputs.* is a workflow-controllable context. Offending lines: `v="${{ steps.ver.outputs.version }}"` and `maj="${{ steps.ver.outputs.major }}"`.

Locations:

- `.github/workflows/release.yml:196`
- `.github/workflows/release.yml:197`

### script-injection (severity: high)

Rule (b): In the 'Run Agent Guard' step of action.yml, the env var $AGENT_GUARD_PATHS (sourced from inputs.paths, a caller-controlled input) is expanded unquoted in the run: block: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted expansion allows the shell to parse metacharacters (`;`, `|`, `&`, `$(...)`, etc.) from the value, enabling command injection. The shellcheck disable comment confirms the intentional unquoting, but it does not eliminate the injection risk.

Locations:

- `action.yml:100`

### github-env-injection (severity: high)

The 'Compute next version' step writes values derived from the user-controlled input ${{ inputs.version }} to $GITHUB_OUTPUT without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). Specifically, `$v` (set from `explicit="${{ inputs.version }}"`) is written via `echo "version=$v" >> "$GITHUB_OUTPUT"`, `echo "branch=release/v${v}" >> "$GITHUB_OUTPUT"`, and `echo "major=v${MA}" >> "$GITHUB_OUTPUT"`. A newline injected into the version input could poison subsequent GITHUB_OUTPUT entries. The regex validation applied to the input does not substitute for the required sanitization before the write.

Locations:

- `.github/workflows/release.yml:70`
- `.github/workflows/release.yml:71`
- `.github/workflows/release.yml:72`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 10 findings across two files:

1. release.yml - script-injection (9 findings): Moved all ${{ }} expressions out of run: blocks into step env: blocks. Each expression is now referenced as a plain environment variable in the shell script. Affected steps: 'Compute next version' (inputs.version, inputs.bump), 'Detect resume state' (steps.ver.outputs.version), 'Bump version in tracked files' (steps.ver.outputs.version), 'Build CHANGELOG entry' (steps.ver.outputs.version), 'Open release PR' (steps.ver.outputs.version, steps.ver.outputs.branch, github.actor, steps.ver.outputs.previous, inputs.bump, inputs.dry_run), 'Auto-merge release PR' (steps.pr.outputs.url), 'Wait for PR to merge' (steps.pr.outputs.url), 'Tag and publish release' (steps.ver.outputs.version, steps.ver.outputs.major).

2. release.yml - github-env-injection (1 finding): Added sanitization in 'Compute next version' using `printf '%s' "$var" | tr -d '\n\r'` before writing version, major, branch, and previous values to $GITHUB_OUTPUT.

3. action.yml - script-injection (1 finding): Replaced unquoted `$AGENT_GUARD_PATHS` expansion with `IFS=' ' read -ra _paths <<< "$AGENT_GUARD_PATHS"` and `"${_paths[@]}"` to safely split and pass space-separated paths as individual quoted arguments, preventing shell metacharacter injection.

