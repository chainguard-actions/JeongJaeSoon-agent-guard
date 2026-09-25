#!/usr/bin/env sh
# Mock gitleaks binary for testing agent-guard action.
# Closely mirrors the interface used by the action's own test fixtures.
# Handles the subcommands that agent-guard uses to call gitleaks:
#   version  - print version string and exit 0
#   dir      - scan a directory for secrets
#   stdin    - scan stdin for secrets
#   detect   - standard gitleaks detect (fallback)
#   *        - any other subcommand: exit 0 (clean)
#
# Secret detection pattern: AGENT_GUARD_TEST_SECRET or PRIVATE KEY
set -u

mode="${1:-}"
case "$mode" in
  version)
    printf '%s\n' "8.30.1"
    exit 0
    ;;

  dir)
    shift
    for arg in "$@"; do
      case "$arg" in
        -*|--*) continue ;;
        *)
          if [ -f "$arg" ] && grep -Eq 'AGENT_GUARD_TEST_SECRET|PRIVATE KEY' "$arg" 2>/dev/null; then
            printf '%s\n' "Finding: REDACTED"
            exit 1
          fi
          if [ -d "$arg" ] && grep -R -E -q 'AGENT_GUARD_TEST_SECRET|PRIVATE KEY' "$arg" 2>/dev/null; then
            printf '%s\n' "Finding: REDACTED"
            exit 1
          fi
          ;;
      esac
    done
    exit 0
    ;;

  stdin)
    shift
    report_path=""
    prev=""
    for arg in "$@"; do
      case "$prev" in
        --report-path) report_path="$arg" ;;
      esac
      case "$arg" in
        --report-path=*) report_path="${arg#--report-path=}" ;;
      esac
      prev="$arg"
    done
    input=$(cat)
    case "$input" in
      *AGENT_GUARD_TEST_SECRET*|*"PRIVATE KEY"*)
        [ -n "$report_path" ] && printf '[{"Secret":"REDACTED"}]\n' > "$report_path"
        printf '%s\n' "Finding: REDACTED"
        exit 1
        ;;
      *)
        [ -n "$report_path" ] && printf '[]\n' > "$report_path"
        exit 0
        ;;
    esac
    ;;

  detect)
    # Standard gitleaks detect command (fallback for any detect-style calls)
    shift
    source_path="."
    report_path=""
    prev=""
    for arg in "$@"; do
      case "$prev" in
        --source|-s) source_path="$arg" ;;
        --report-path) report_path="$arg" ;;
      esac
      case "$arg" in
        --source=*) source_path="${arg#--source=}" ;;
        --report-path=*) report_path="${arg#--report-path=}" ;;
      esac
      prev="$arg"
    done
    if [ -f "$source_path" ] && grep -Eq 'AGENT_GUARD_TEST_SECRET|PRIVATE KEY' "$source_path" 2>/dev/null; then
      [ -n "$report_path" ] && printf '[{"Secret":"REDACTED"}]\n' > "$report_path"
      printf '%s\n' "Finding: REDACTED"
      exit 1
    fi
    if [ -d "$source_path" ] && grep -R -E -q 'AGENT_GUARD_TEST_SECRET|PRIVATE KEY' "$source_path" 2>/dev/null; then
      [ -n "$report_path" ] && printf '[{"Secret":"REDACTED"}]\n' > "$report_path"
      printf '%s\n' "Finding: REDACTED"
      exit 1
    fi
    [ -n "$report_path" ] && printf '[]\n' > "$report_path"
    exit 0
    ;;

  *)
    # Unknown subcommand: exit 0 (clean)
    exit 0
    ;;
esac
