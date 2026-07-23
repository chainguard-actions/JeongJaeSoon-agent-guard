<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v2.0.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v2.0.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ ... }} expressions are interpolated directly inside run: shell command strings in release.yml, violating rule (a). This allows YAML-time substitution of attacker-controllable values into shell code before the shell processes them, enabling command injection.

Affected expressions and steps:
- 'Compute next version': explicit="${{ inputs.version }}" and case "${{ inputs.bump }}" in
- 'Detect resume state': v="${{ steps.ver.outputs.version }}"
- 'Bump version in tracked files': v="${{ steps.ver.outputs.version }}"
- 'Build CHANGELOG entry': v="${{ steps.ver.outputs.version }}"
- 'Open release PR': v="${{ steps.ver.outputs.version }}", br="${{ steps.ver.outputs.branch }}", ${{ github.actor }}, ${{ steps.ver.outputs.previous }}, ${{ inputs.bump }}, ${{ inputs.dry_run }}
- 'Auto-merge release PR': gh pr merge "${{ steps.pr.outputs.url }}"
- 'Wait for PR to merge': gh pr view "${{ steps.pr.outputs.url }}"
- 'Tag and publish release': v="${{ steps.ver.outputs.version }}", maj="${{ steps.ver.outputs.major }}"

Fix: move all values into env: variables and reference them as quoted shell variables (e.g., "$VAR") inside run: blocks.

Locations:

- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:57`
- `.github/workflows/release.yml:73`
- `.github/workflows/release.yml:113`
- `.github/workflows/release.yml:133`
- `.github/workflows/release.yml:152`
- `.github/workflows/release.yml:153`
- `.github/workflows/release.yml:163`
- `.github/workflows/release.yml:164`
- `.github/workflows/release.yml:165`
- `.github/workflows/release.yml:166`
- `.github/workflows/release.yml:180`
- `.github/workflows/release.yml:196`
- `.github/workflows/release.yml:222`
- `.github/workflows/release.yml:223`

### script-injection (severity: high)

In action.yml, the 'Run Agent Guard' step uses $AGENT_GUARD_PATHS unquoted in the run: shell command (rule b violation): `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The variable holds inputs.paths (set via env: AGENT_GUARD_PATHS: ${{ inputs.paths }}). An attacker-controlled path value containing shell metacharacters (semicolons, pipes, backticks, glob characters, etc.) could be interpreted by the shell. The # shellcheck disable=SC2086 comment confirms the unquoted expansion is intentional for word-splitting, but the check requires double-quoting of all env vars holding workflow-controllable data.

Locations:

- `action.yml:80`

### github-env-injection (severity: high)

In release.yml, the 'Compute next version' step writes values derived from inputs.version and inputs.bump directly to $GITHUB_OUTPUT without the required sanitization step (printf '%s' ... | tr -d '\n\r'). The variable $v is populated from ${{ inputs.version }} (directly interpolated into the shell), and then written unsanitized: `echo "version=$v" >> "$GITHUB_OUTPUT"`, `echo "major=v${MA}" >> "$GITHUB_OUTPUT"`, and `echo "branch=release/v${v}" >> "$GITHUB_OUTPUT"`. A newline-containing input value could inject additional key=value pairs into GITHUB_OUTPUT, poisoning subsequent steps that consume these outputs.

Locations:

- `.github/workflows/release.yml:62`
- `.github/workflows/release.yml:63`
- `.github/workflows/release.yml:64`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed all three findings:

1. **script-injection in release.yml** (8 steps affected): Moved all `${{ ... }}` expressions out of `run:` shell strings into `env:` blocks. Steps affected: 'Compute next version' (inputs.version, inputs.bump), 'Detect resume state' (steps.ver.outputs.version), 'Bump version in tracked files' (steps.ver.outputs.version), 'Build CHANGELOG entry' (steps.ver.outputs.version), 'Open release PR' (steps.ver.outputs.version, steps.ver.outputs.branch, github.actor, steps.ver.outputs.previous, inputs.bump, inputs.dry_run), 'Auto-merge release PR' (steps.pr.outputs.url), 'Wait for PR to merge' (steps.pr.outputs.url), 'Tag and publish release' (steps.ver.outputs.version, steps.ver.outputs.major). All values are now referenced as quoted `$VAR_NAME` shell variables.

2. **github-env-injection in release.yml**: The 'Compute next version' step now sanitizes v, MA, and cur with `printf '%s' "$var" | tr -d '\n\r'` before writing to $GITHUB_OUTPUT, preventing newline injection.

3. **script-injection in action.yml**: Replaced unquoted `$AGENT_GUARD_PATHS` word-splitting with `IFS=' ' read -ra path_args <<< "$AGENT_GUARD_PATHS"` and `"${path_args[@]}"`, so each path element is passed as a separate properly-quoted argument, preventing shell metacharacter injection.

