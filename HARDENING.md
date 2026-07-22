<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.5.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.5.0** was hardened automatically. 9 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The 'Compute next version' run: block directly interpolates ${{ inputs.version }} and ${{ inputs.bump }} into shell commands. These are workflow_dispatch inputs controlled by the caller and are interpolated before the shell parses the script, enabling command injection. Offending lines: `explicit="${{ inputs.version }}"` and `case "${{ inputs.bump }}" in`.

Locations:

- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:60`

### script-injection (severity: high)

Rule (a): The 'Detect resume state' run: block directly interpolates ${{ steps.ver.outputs.version }} into a shell variable assignment: `v="${{ steps.ver.outputs.version }}"`.

Locations:

- `.github/workflows/release.yml:79`

### script-injection (severity: high)

Rule (a): The 'Bump version in tracked files' run: block directly interpolates ${{ steps.ver.outputs.version }} into a shell variable assignment: `v="${{ steps.ver.outputs.version }}"`.

Locations:

- `.github/workflows/release.yml:107`

### script-injection (severity: high)

Rule (a): The 'Build CHANGELOG entry' run: block directly interpolates ${{ steps.ver.outputs.version }} into a shell variable assignment: `v="${{ steps.ver.outputs.version }}"`.

Locations:

- `.github/workflows/release.yml:127`

### script-injection (severity: high)

Rule (a): The 'Open release PR' run: block directly interpolates multiple expressions into shell commands: `v="${{ steps.ver.outputs.version }}"`, `br="${{ steps.ver.outputs.branch }}"`, `"${{ github.actor }}"`, `"${{ steps.ver.outputs.previous }}"`, `"${{ inputs.bump }}"`, and `"${{ inputs.dry_run }}"`. github.actor and inputs.* are attacker-controllable.

Locations:

- `.github/workflows/release.yml:141`

### script-injection (severity: high)

Rule (a): The 'Auto-merge release PR' run: block directly interpolates ${{ steps.pr.outputs.url }} into a shell command: `gh pr merge "${{ steps.pr.outputs.url }}" --squash --delete-branch --auto`.

Locations:

- `.github/workflows/release.yml:168`

### script-injection (severity: high)

Rule (a): The 'Wait for PR to merge' run: block directly interpolates ${{ steps.pr.outputs.url }} into a shell command: `state=$(gh pr view "${{ steps.pr.outputs.url }}" --json state -q .state)`.

Locations:

- `.github/workflows/release.yml:179`

### script-injection (severity: high)

Rule (a): The 'Tag and publish release' run: block directly interpolates ${{ steps.ver.outputs.version }} and ${{ steps.ver.outputs.major }} into shell variable assignments: `v="${{ steps.ver.outputs.version }}"` and `maj="${{ steps.ver.outputs.major }}"`.

Locations:

- `.github/workflows/release.yml:191`

### script-injection (severity: high)

Rule (b): The 'Run Agent Guard' step in action.yml expands $AGENT_GUARD_PATHS unquoted in the run: block: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. AGENT_GUARD_PATHS holds ${{ inputs.paths }}, a caller-controlled value. The unquoted expansion allows shell metacharacter injection (word splitting, glob expansion, etc.).

Locations:

- `action.yml:93`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed all 9 script-injection findings:

1. release.yml 'Compute next version': moved ${{ inputs.version }} and ${{ inputs.bump }} into env: block as INPUT_VERSION and INPUT_BUMP.
2. release.yml 'Detect resume state': moved ${{ steps.ver.outputs.version }} into env: block as VER_VERSION.
3. release.yml 'Bump version in tracked files': moved ${{ steps.ver.outputs.version }} into env: block as VER_VERSION.
4. release.yml 'Build CHANGELOG entry': moved ${{ steps.ver.outputs.version }} into env: block as VER_VERSION.
5. release.yml 'Open release PR': moved all 6 expressions (${{ steps.ver.outputs.version }}, ${{ steps.ver.outputs.branch }}, ${{ github.actor }}, ${{ steps.ver.outputs.previous }}, ${{ inputs.bump }}, ${{ inputs.dry_run }}) into env: block.
6. release.yml 'Auto-merge release PR': moved ${{ steps.pr.outputs.url }} into env: block as PR_URL.
7. release.yml 'Wait for PR to merge': moved ${{ steps.pr.outputs.url }} into env: block as PR_URL.
8. release.yml 'Tag and publish release': moved ${{ steps.ver.outputs.version }} and ${{ steps.ver.outputs.major }} into env: block as VER_VERSION and VER_MAJOR.
9. action.yml 'Run Agent Guard': replaced unquoted $AGENT_GUARD_PATHS expansion with read -ra paths_array <<< "$AGENT_GUARD_PATHS" and "${paths_array[@]}" to safely handle space-separated paths without shell metacharacter injection.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In the 'Compute next version' step of .github/workflows/release.yml, added explicit `tr -d '\n\r'` sanitization for all values written to $GITHUB_OUTPUT. Three sanitized variables are now computed: `safe_v=$(printf '%s' "$v" | tr -d '\n\r')`, `safe_ma=$(printf '%s' "$MA" | tr -d '\n\r')`, and `safe_cur=$(printf '%s' "$cur" | tr -d '\n\r')`. These sanitized values are then used in the echo statements that write to $GITHUB_OUTPUT, preventing potential newline injection attacks even though a regex validation was already in place for the explicit version input.

