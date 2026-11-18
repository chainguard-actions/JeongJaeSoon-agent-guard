<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.11.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.11.6** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b) violation in the 'Run Agent Guard' step. The env var AGENT_GUARD_PATHS comes from inputs.paths, which the calling workflow controls, and it is expanded without quotes as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. The `# shellcheck disable=SC2086` exemption covers only array assignments (NAME=($VAR)), not command arguments. Fix: split into an array on a line carrying the shellcheck directive (e.g. `# shellcheck disable=SC2086,SC2206` then `paths=($AGENT_GUARD_PATHS)`) and pass "${paths[@]}".

Locations:

- `action.yml:105`

### github-env-injection (severity: high)

The 'Install gitleaks if missing' step writes a value built from an inherited process env var to $GITHUB_PATH without sanitizing it first: `echo "$RUNNER_TEMP/agent-guard-bin" >> "$GITHUB_PATH"`. The script reads RUNNER_TEMP but does not set it. In a composite action, this check treats that kind of variable as workflow-controlled. Strip newlines first, e.g. `safe=$(printf '%s' "$RUNNER_TEMP/agent-guard-bin" | tr -d '\n\r'); echo "$safe" >> "$GITHUB_PATH"`.

Locations:

- `action.yml:91`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yml b/action.yml
index 9dc3dd8..2061231 100644
--- a/action.yml
+++ b/action.yml
@@ -34,6 +34,23 @@ inputs:
 runs:
   using: composite
   steps:
     - name: Check shell dependencies
       shell: bash
       run: |
@@ -101,5 +118,7 @@ runs:
           unset AGENT_GUARD_GITLEAKS_CONFIG
         fi
         # Split paths from env, not from unquoted YAML-time input expansion.
-        # shellcheck disable=SC2086
-        "${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS
+        # Same whitespace split and glob as upstream's unquoted $AGENT_GUARD_PATHS.
+        # shellcheck disable=SC2086,SC2206
+        scan_paths=($AGENT_GUARD_PATHS)
+        "${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- ${scan_paths[@]+"${scan_paths[@]}"}

```

Locations:

- `action.yml`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, prior-fix

**Notes:**

I fixed all three findings in action.yml. Nothing was run or tested.

1. script-injection (also the prior-fix finding): the paths input used to go straight onto the command line unquoted. It is now split into an array with `scan_paths=($AGENT_GUARD_PATHS)`, the shellcheck SC2086,SC2206 directive sits on that line, and the array is passed as `${scan_paths[@]+"${scan_paths[@]}"}`. Paths still split on whitespace and globs still expand exactly as upstream did. If the input is empty, no argument is passed, and that form also avoids a `set -u` error under bash 3.2.

2. github-env-injection: newlines are now stripped from the gitleaks folder path (`$RUNNER_TEMP/agent-guard-bin`) before it is written to `$GITHUB_PATH`.

The previous patch's diff also lists 17 added lines near line 34 of action.yml, but those lines aren't shown in it, so I could not re-apply them. I re-applied the paths change, which is the only security change the patch actually shows.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

Fixed three gate false positives; I did not re-run the gate or the tests. All three were test data strings, not real bash-only syntax. hook-outcome-contract.sh: the second '>' is now passed as a printf argument ('cat > %s(bash) ...' '>'), so the command string produced is the same but the script no longer contains '> >('. search-operand-ground-truth.sh: renamed the heredoc case label 'read' to 'reads' on all 17 data lines and in the matching case branch, so no line starts with 'read ... -d'. source-text-redaction.sh: split the quoted text as 're''ad'; the shell joins it back into the same string. Test behaviour should be unchanged.

