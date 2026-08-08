#!/usr/bin/env bash
set -euo pipefail

script=entrypoint.sh
grep -F 'ISO_TMP="/iso/win10.iso.part"' "$script"
grep -F 'mv "$ISO_TMP" "$ISO_PATH"' "$script"
grep -F 'trap cleanup EXIT INT TERM' "$script"
grep -F 'wait -n "$QEMU_PID" "$NOVNC_PID"' "$script"
if grep -Fq 'tail -f /dev/null' "$script"; then
  echo 'entrypoint still masks process failures' >&2
  exit 1
fi
