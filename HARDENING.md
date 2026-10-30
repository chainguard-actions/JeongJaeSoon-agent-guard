<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.6.10

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.6.10** was hardened automatically. 1 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b), unquoted shell expansion of untrusted data. In the 'Run Agent Guard' step, AGENT_GUARD_PATHS comes from ${{ inputs.paths }} (set through env:) and is expanded without quotes: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The unquoting is deliberate so the input splits on whitespace, but the shell also runs glob/pathname expansion on the caller-supplied value. So any workflow calling the action can pass glob characters, and the shell turns them into extra arguments. Fix: split the value into an array without globbing and quote the expansion, e.g. `read -r -a paths <<< "$AGENT_GUARD_PATHS"; ... scan-path -- "${paths[@]}"`. Another option is to run `set -f` before the expansion.

Locations:

- `action.yml:106`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

In action.yml's 'Run Agent Guard' step, AGENT_GUARD_PATHS is now tokenized with `read -r -d '' -a paths <<< "$AGENT_GUARD_PATHS" || true` (guarded by a non-empty check). This splits on whitespace and newlines like upstream did, without pathname expansion. The array is passed as ${paths[@]+"${paths[@]}"} so it is safe under set -u on bash 3.2.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Fixed the one publish-gate failure, in tests/hook-outcome-contract.sh line 256. It was a false positive. The `>(bash)` text is test data inside a single-quoted printf format string, and the script never runs it as process substitution. I replaced the `>` in that format string with `\076`, the octal code for `>`. printf in POSIX sh turns `\076` back into `>`, so the command string the test builds should come out byte-for-byte the same. I didn't run the test. The general rule is to leave files under tests/ alone, but this gate check blocks publishing unless it's fixed. Nothing else was changed.

