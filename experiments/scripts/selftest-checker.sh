#!/usr/bin/env bash
# Validates check-run.sh with two SYNTHETIC fixtures (experiments/checker-selftest/).
# This tests the checker only — its output is never an experiment result.
#
#   experiments/scripts/selftest-checker.sh <commit>
#
# Expected: strong.spec.ts → 3/3 bugs caught, no static warnings
#           weak.spec.ts   → 0/3 bugs caught, static warnings present
# Uses its own temporary RUNS_DIR and EVIDENCE_DIR, so it never touches real runs.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

[[ -n "${1:-}" ]] || { echo "usage: $0 <commit>" >&2; exit 1; }
SHA="$(resolve_commit "$1")"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
export RUNS_DIR="$WORK/runs" EVIDENCE_DIR="$WORK/evidence"
FAILURES=0

expect_result() { # name, expected caught, expect warnings (yes/no)
  local name="$1" caught="$2" warnings="$3" id="selftest-$1" out
  "$ROOT/experiments/scripts/prepare-run.sh" main full "$SHA" "$id" > /dev/null
  git -C "$ROOT" show "$SHA:experiments/checker-selftest/$name.spec.ts" \
    > "$RUNS_DIR/$id/tests/api/bookings/selftest-$name.spec.ts"
  out="$("$ROOT/experiments/scripts/check-run.sh" "$id")"
  rm -rf "${RUNS_DIR:?}/$id"

  if grep -q "Bugs caught: $caught / 3" <<< "$out"; then
    echo "✅ $name: bugs caught $caught/3"
  else
    echo "❌ $name: expected $caught/3, got: $(grep 'Bugs caught' <<< "$out")"; FAILURES=$((FAILURES + 1))
  fi
  if grep -q "^- ⚠️" <<< "$out"; then got=yes; else got=no; fi
  if [[ "$got" == "$warnings" ]]; then
    echo "✅ $name: static warnings = $warnings"
  else
    echo "❌ $name: expected static warnings = $warnings, got $got"; FAILURES=$((FAILURES + 1))
  fi
}

expect_result strong 3 no
expect_result weak 0 yes

if [[ $FAILURES -eq 0 ]]; then echo "Checker self-test passed."; else echo "Checker self-test FAILED ($FAILURES)."; exit 1; fi
