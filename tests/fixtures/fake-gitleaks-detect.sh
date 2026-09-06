#!/usr/bin/env sh
# Fake gitleaks for testing: exits 1 when AGENT_GUARD_TEST_SECRET is found
set -u
mode="${1:-}"
case "$mode" in
  version|--version)
    printf '8.30.1-fake\n'
    exit 0
    ;;
  dir|detect|stdin)
    # Find the scan target path from arguments.
    # Priority: --source <path> flag, then first positional non-flag argument.
    scan_target=""
    skip_next=0
    prev=""
    for arg in "$@"; do
      if [ "$skip_next" = "1" ]; then
        skip_next=0
        prev="$arg"
        continue
      fi
      case "$prev" in
        --source|-s)
          scan_target="$arg"
          prev="$arg"
          continue
          ;;
      esac
      case "$arg" in
        --source|-s)
          prev="$arg"
          continue
          ;;
        --report-path|--config|-c|--log-opts|--baseline-path|--exit-code)
          skip_next=1
          prev="$arg"
          continue
          ;;
        --*)
          prev="$arg"
          continue
          ;;
        -*)
          prev="$arg"
          continue
          ;;
        *)
          if [ "$arg" != "$mode" ] && [ -n "$arg" ] && [ -z "$scan_target" ]; then
            scan_target="$arg"
          fi
          ;;
      esac
      prev="$arg"
    done
    if [ -n "$scan_target" ]; then
      if grep -rqE 'AGENT_GUARD_TEST_SECRET' "$scan_target" 2>/dev/null; then
        printf 'Finding: secret detected\n'
        exit 1
      fi
    fi
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
