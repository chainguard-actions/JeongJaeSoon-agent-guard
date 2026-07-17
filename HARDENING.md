<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v2.0.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v2.0.0** was hardened automatically. 10 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b): The 'Run Agent Guard' step in action.yml uses $AGENT_GUARD_PATHS unquoted in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. AGENT_GUARD_PATHS is set from `${{ inputs.paths }}` (user-controlled). The unquoted expansion allows shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) in the input to be interpreted by the shell, enabling command injection.

Locations:

- `action.yml:104`

### script-injection (severity: high)

Rule (a): The 'Compute next version' step in release.yml directly interpolates `${{ inputs.version }}` and `${{ inputs.bump }}` inside the run: shell script. Offending lines: `explicit="${{ inputs.version }}"` and `case "${{ inputs.bump }}" in`. These workflow_dispatch inputs are attacker-controllable and are substituted into the shell script before execution, enabling command injection.

Locations:

- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:62`

### script-injection (severity: high)

Rule (a): The 'Detect resume state' step in release.yml directly interpolates `${{ steps.ver.outputs.version }}` inside the run: shell script: `v="${{ steps.ver.outputs.version }}"`. Step outputs are workflow-controllable and must not be interpolated directly into shell commands.

Locations:

- `.github/workflows/release.yml:72`

### script-injection (severity: high)

Rule (a): The 'Bump version in tracked files' step in release.yml directly interpolates `${{ steps.ver.outputs.version }}` inside the run: shell script: `v="${{ steps.ver.outputs.version }}"`. Step outputs are workflow-controllable and must not be interpolated directly into shell commands.

Locations:

- `.github/workflows/release.yml:120`

### script-injection (severity: high)

Rule (a): The 'Build CHANGELOG entry' step in release.yml directly interpolates `${{ steps.ver.outputs.version }}` inside the run: shell script: `v="${{ steps.ver.outputs.version }}"`. Step outputs are workflow-controllable and must not be interpolated directly into shell commands.

Locations:

- `.github/workflows/release.yml:137`

### script-injection (severity: high)

Rule (a): The 'Open release PR' step in release.yml directly interpolates multiple ${{ }} expressions inside the run: shell script, including: `v="${{ steps.ver.outputs.version }}"`, `br="${{ steps.ver.outputs.branch }}"`, `"${{ github.actor }}"`, `"${{ steps.ver.outputs.previous }}"`, `"${{ inputs.bump }}"`, and `"${{ inputs.dry_run }}"`. These are all workflow-controllable values interpolated directly into shell commands.

Locations:

- `.github/workflows/release.yml:152`
- `.github/workflows/release.yml:153`
- `.github/workflows/release.yml:162`
- `.github/workflows/release.yml:163`
- `.github/workflows/release.yml:164`
- `.github/workflows/release.yml:165`

### script-injection (severity: high)

Rule (a): The 'Auto-merge release PR' step in release.yml directly interpolates `${{ steps.pr.outputs.url }}` inside the run: shell script: `gh pr merge "${{ steps.pr.outputs.url }}" --squash --delete-branch --auto`. Step outputs are workflow-controllable and must not be interpolated directly into shell commands.

Locations:

- `.github/workflows/release.yml:177`

### script-injection (severity: high)

Rule (a): The 'Wait for PR to merge' step in release.yml directly interpolates `${{ steps.pr.outputs.url }}` inside the run: shell script: `state=$(gh pr view "${{ steps.pr.outputs.url }}" --json state -q .state)`. Step outputs are workflow-controllable and must not be interpolated directly into shell commands.

Locations:

- `.github/workflows/release.yml:185`

### script-injection (severity: high)

Rule (a): The 'Tag and publish release' step in release.yml directly interpolates `${{ steps.ver.outputs.version }}` and `${{ steps.ver.outputs.major }}` inside the run: shell script: `v="${{ steps.ver.outputs.version }}"` and `maj="${{ steps.ver.outputs.major }}"`. Step outputs are workflow-controllable and must not be interpolated directly into shell commands.

Locations:

- `.github/workflows/release.yml:196`
- `.github/workflows/release.yml:197`

### github-env-injection (severity: high)

The 'Compute next version' step in release.yml writes user-controlled values to $GITHUB_OUTPUT without the required `printf '%s' ... | tr -d '\n\r'` sanitization. Specifically: `echo "version=$v" >> "$GITHUB_OUTPUT"`, `echo "major=v${MA}" >> "$GITHUB_OUTPUT"`, `echo "branch=release/v${v}" >> "$GITHUB_OUTPUT"`, and `echo "previous=${cur}" >> "$GITHUB_OUTPUT"`. The variable `$v` is derived from `inputs.version` (directly interpolated via `${{ inputs.version }}`), and `${cur}` may come from git tags. An attacker-controlled newline in these values could inject arbitrary key=value pairs into GITHUB_OUTPUT, poisoning subsequent steps.

Locations:

- `.github/workflows/release.yml:66`
- `.github/workflows/release.yml:67`
- `.github/workflows/release.yml:68`
- `.github/workflows/release.yml:69`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all 10 findings across action.yml and .github/workflows/release.yml:

1. action.yml: Fixed unquoted $AGENT_GUARD_PATHS by splitting into a bash array with `IFS=' ' read -ra _paths <<< "$AGENT_GUARD_PATHS"` and passing `"${_paths[@]}"` to the command.

2. release.yml 'Compute next version': Moved ${{ inputs.version }} and ${{ inputs.bump }} into env: block (INPUT_VERSION, INPUT_BUMP). Added printf/tr sanitization before all four GITHUB_OUTPUT writes to prevent newline injection.

3. release.yml 'Detect resume state': Moved ${{ steps.ver.outputs.version }} into env: block as VER_VERSION.

4. release.yml 'Bump version in tracked files': Moved ${{ steps.ver.outputs.version }} into env: block as VER_VERSION.

5. release.yml 'Build CHANGELOG entry': Moved ${{ steps.ver.outputs.version }} into env: block as VER_VERSION.

6. release.yml 'Open release PR': Moved all six ${{ }} expressions (steps.ver.outputs.version, steps.ver.outputs.branch, github.actor, steps.ver.outputs.previous, inputs.bump, inputs.dry_run) into env: block.

7. release.yml 'Auto-merge release PR': Moved ${{ steps.pr.outputs.url }} into env: block as PR_URL.

8. release.yml 'Wait for PR to merge': Moved ${{ steps.pr.outputs.url }} into env: block as PR_URL.

9. release.yml 'Tag and publish release': Moved ${{ steps.ver.outputs.version }} and ${{ steps.ver.outputs.major }} into env: block as VER_VERSION and VER_MAJOR.

