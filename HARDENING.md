<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v1.3.7

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v1.3.7** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation: In the 'Run Agent Guard' step, the env var `$AGENT_GUARD_PATHS` — which holds the value of `inputs.paths` (attacker-controlled) — is expanded **unquoted** in the `run:` shell command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. An attacker can supply a `paths` input containing shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.) to inject arbitrary commands. The `# shellcheck disable=SC2086` comment confirms the unquoted expansion is intentional for word-splitting, but word-splitting does not prevent command injection. The value must be sanitized or the argument passing redesigned (e.g. using an array or `xargs`) to prevent injection.

Locations:

- `action.yml:96`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed the script injection vulnerability in the 'Run Agent Guard' step of action.yml (line 96). The unquoted `$AGENT_GUARD_PATHS` expansion (`-- $AGENT_GUARD_PATHS`) was replaced with a safe bash array approach: `IFS=' ' read -ra paths <<< "$AGENT_GUARD_PATHS"` followed by `"${paths[@]}"`. This splits the space-separated paths into an array without interpreting shell metacharacters, then passes each path as a properly-quoted argument. The `# shellcheck disable=SC2086` comment was also removed as it is no longer needed.

### Iteration 2

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

Fixed all three findings in the GitHub Actions workflows:

1. **unpinned-uses**: Pinned all 7 unpinned action references to full 40-char SHAs with tag comments preserved:
   - actions/checkout@v5 → @fbc6f3992d24b796d5a048ff273f7fcc4a7b6c09 (ci.yml ×2, codex-review.yml, plugin-validation.yml, release.yml)
   - openai/codex-action@v1 → @52fe01ec70a42f454c9d2ebd47598f9fd6893d56 (codex-review.yml)
   - actions/github-script@v7 → @f28e40c7f34bde8b3046d885e986cb6290c5673b (codex-review.yml)

2. **script-injection**: Moved all ${{ }} expressions out of run: shell scripts in release.yml into env: blocks. All workflow-controlled values (inputs.version, inputs.bump, inputs.dry_run, github.actor, steps.ver.outputs.*, steps.pr.outputs.url) are now referenced as plain shell environment variables.

3. **github-env-injection**: Added `printf '%s' "$val" | tr -d '\n\r'` sanitization before every GITHUB_OUTPUT write where the value originates from user-controlled input (version, major, branch, previous from inputs; PR URL from gh pr create). This prevents newline injection attacks that could overwrite downstream step outputs.

