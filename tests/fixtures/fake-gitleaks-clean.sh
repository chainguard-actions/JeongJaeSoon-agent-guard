#!/usr/bin/env sh
# Fake gitleaks for testing: always reports clean (exit 0)
set -u
case "${1:-}" in
  version|--version) printf '8.30.1-fake\n'; exit 0 ;;
  dir|detect|stdin) exit 0 ;;
  *) exit 0 ;;
esac
