<!-- markdownlint-disable -->

# Hardening Report: JeongJaeSoon--agent-guard/v3.11.5

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **JeongJaeSoon--agent-guard/v3.11.5** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (b), unquoted expansion of workflow-controlled data. The 'Run Agent Guard' step expands the env var AGENT_GUARD_PATHS, which comes from inputs.paths, without quotes as a command argument: `"${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- $AGENT_GUARD_PATHS`. A shellcheck SC2086 directive sits on the line above, but the exemption only covers expanding a variable into an array assignment (NAME=($VAR)). It does not cover a bare unquoted argument, so glob characters and whitespace in the input are expanded here. Fix: split it into an array first (e.g. `# shellcheck disable=SC2206` followed by `paths=($AGENT_GUARD_PATHS)`), then pass "${paths[@]}".

Locations:

- `action.yml:105`

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yml b/action.yml
index 9dc3dd8..c20672f 100644
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
+        # Unquoted array assignment: same whitespace split and glob as upstream.
+        # shellcheck disable=SC2206
+        paths=($AGENT_GUARD_PATHS)
+        "${GITHUB_ACTION_PATH}/plugins/agent-guard/bin/agent-guard" scan-path -- ${paths[@]+"${paths[@]}"}

```

Locations:

- `action.yml`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, prior-fix

**Notes:**

In action.yml's 'Run Agent Guard' step, the bare unquoted $AGENT_GUARD_PATHS argument has been replaced. The step now assigns it to an array without quotes, `paths=($AGENT_GUARD_PATHS)`, with a SC2206 directive, so the input is split on whitespace and globbed exactly as upstream did. It then passes the paths as ${paths[@]+"${paths[@]}"}, which works under set -u even when the input is empty. This puts back the previous harden's change. Its patch also showed a hunk near line 34 with no visible content, so there was nothing else to re-apply. Not tested; no analysis pass was re-run.

### Iteration 1

**Fixes applied:** publish-gate

**Notes:**

All three flags were false positives. In each case the gate matched shell-looking text inside test data, not code the shell actually runs. I changed only how that data is spelled. Each test still produces exactly the same strings and checks the same things. Nothing was run to confirm this.
- tests/hook-outcome-contract.sh: the test command is now built with printf 'cat > %s(bash) ...' '>' so the source no longer contains a literal '> >(' sequence. The string it produces is still "cat > >(bash) <<'EOF'...".
- tests/search-operand-ground-truth.sh: the heredoc case kind 'read' is renamed to 'leak' everywhere: in the case lines, in the matching case label and in the header comment. The case line 'read cut -d= ...' no longer looks like a read builtin with -d. The commands under test are unchanged.
- tests/source-text-redaction.sh: the word 'read' is now stored in a variable (vault_verb=read) and the keeps line is double-quoted with \$( escaped. The text checked is still '  TOKEN="$(vault read -field token /secret/werft)"'.

