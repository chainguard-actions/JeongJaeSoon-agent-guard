<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.3.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.3.4** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ ... }} expressions are interpolated directly inside run: shell command strings in release.yml (sub-rule a). This allows YAML-time template substitution to inject arbitrary shell code before the shell ever parses the string. Affected expressions include attacker-controllable workflow_dispatch inputs: `explicit="${{ inputs.version }}"` (line 46), `case "${{ inputs.bump }}" in` (line 63), `"${{ inputs.bump }}"` (line 188), `"${{ inputs.dry_run }}"` (line 189); github context: `"${{ github.actor }}"` (line 186); and step outputs: `v="${{ steps.ver.outputs.version }}"` (lines 81, 131, 152, 172, 228), `br="${{ steps.ver.outputs.branch }}"` (line 173), `"${{ steps.ver.outputs.previous }}"` (line 187), `maj="${{ steps.ver.outputs.major }}"` (line 229), `"${{ steps.pr.outputs.url }}"` (lines 203, 212). All values should be passed via env: variables and then referenced as quoted shell variables.

Locations:

- `.github/workflows/release.yml:46`
- `.github/workflows/release.yml:63`
- `.github/workflows/release.yml:81`
- `.github/workflows/release.yml:131`
- `.github/workflows/release.yml:152`
- `.github/workflows/release.yml:172`
- `.github/workflows/release.yml:173`
- `.github/workflows/release.yml:186`
- `.github/workflows/release.yml:187`
- `.github/workflows/release.yml:188`
- `.github/workflows/release.yml:189`
- `.github/workflows/release.yml:203`
- `.github/workflows/release.yml:212`
- `.github/workflows/release.yml:228`
- `.github/workflows/release.yml:229`

### script-injection (severity: high)

Sub-rule (b): In action.yml's 'Run Agent Guard' step, the env variable $AGENT_GUARD_PATHS (which holds the value of inputs.paths) is expanded unquoted in the shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An unquoted shell variable expansion allows the shell to parse metacharacters (semicolons, pipes, ampersands, glob characters, whitespace word-splitting) from the value, enabling command injection by a caller who supplies a malicious paths input. The comment acknowledges this is intentional for word-splitting, but it still constitutes a script-injection risk per the check rules.

Locations:

- `action.yml:96`

### unpinned-uses (severity: high)

The action uses actions/checkout@v5 (a mutable tag reference) instead of a pinned 40-character commit SHA. Mutable tags can be moved by the upstream repository owner to point to a different — potentially malicious — commit, enabling supply-chain attacks. Affected references: `uses: actions/checkout@v5` in ci.yml (lines 18 and 31) and release.yml (line 38). Fix by pinning to the full SHA, e.g. `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4`.

Locations:

- `.github/workflows/ci.yml:18`
- `.github/workflows/ci.yml:31`
- `.github/workflows/release.yml:38`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses

**Notes:**

Fixed all three findings:
1. unpinned-uses: Pinned actions/checkout@v5 to full SHA 93cb6efe18208431cddfb8368fd83d5badbf9bfd in both ci.yml (2 occurrences) and release.yml (1 occurrence).
2. script-injection (release.yml): Moved all ${{ inputs.* }}, ${{ github.actor }}, and ${{ steps.*.outputs.* }} expressions from run: shell strings into env: blocks. Shell scripts now reference plain environment variables ($INPUT_VERSION, $INPUT_BUMP, $VER_VERSION, $VER_BRANCH, $GITHUB_ACTOR, $VER_PREVIOUS, $INPUT_DRY_RUN, $VER_MAJOR, $PR_URL). The if: conditions retain ${{ }} which is safe (evaluated by GitHub Actions, not the shell).
3. script-injection (action.yml): Replaced unquoted $AGENT_GUARD_PATHS expansion with IFS=' ' read -ra path_args <<< "$AGENT_GUARD_PATHS" and "${path_args[@]}" to safely split space-separated paths without exposing shell metacharacters.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In the 'Compute next version' step of release.yml, added sanitization of the user-controlled `$v` variable (from `INPUT_VERSION`) and `$cur` before writing to `$GITHUB_OUTPUT`. Added `safe_v=$(printf '%s' "$v" | tr -d '\n\r')` and `safe_cur=$(printf '%s' "$cur" | tr -d '\n\r')` before the GITHUB_OUTPUT writes, and updated all four echo statements to use `${safe_v}` and `${safe_cur}` instead of the raw variables. This prevents the newline injection attack where bash's `grep` regex check allows inputs like `1.2.3\n` (since `$` matches before a newline), but the trailing newline would then be written into GITHUB_OUTPUT enabling environment-file injection.

