#!/usr/bin/env bash
# Objective checks on one finished run. Writes $EVIDENCE_DIR/<run-id>/agent.diff and check-results.md.
#
#   experiments/scripts/check-run.sh <run-id>
#
# Read-only on the run folder: every check runs on a temporary copy in your own temp folder,
# so the agent's files, git state and test output stay exactly as the agent left them.
# _transcript/ (the session transcripts) is evidence, not code: it's left out of the diff and checks.
#
# Uses its own copy of the service, exported from the run's pinned commit, on CHECK_PORT
# (default 4011), so it doesn't interfere with a service you're running for an agent on 4010.
#
# 1. What changed (vs. the baseline commit)
# 2. Type check
# 3. Booking tests against the correct service (should pass)
# 4. Booking tests against each injected bug (should FAIL = bug caught), with likely causes
# 5. Forbidden patterns and framework bypasses in the agent's changes
set -uo pipefail
source "$(dirname "$0")/lib.sh"

ID="${1:-}"
[[ -n "$ID" ]] || { echo "usage: $0 <run-id created by prepare-run.sh>" >&2; exit 1; }
require_run_id "$ID"
RUN_DIR="$RUNS_DIR/$ID"
EVIDENCE="$EVIDENCE_DIR/$ID"
[[ -d "$RUN_DIR/.git" ]] || { echo "no run folder at $RUN_DIR" >&2; exit 1; }
[[ -f "$EVIDENCE/run.meta" ]] || { echo "no metadata at $EVIDENCE/run.meta" >&2; exit 1; }

SHA="$(meta_value "$ID" commit)"
[[ "$SHA" =~ ^[0-9a-f]{40}$ ]] || { echo "can't read the pinned commit from $EVIDENCE/run.meta" >&2; exit 1; }
SERVICE="$(export_service "$SHA")" || exit 1
URL="http://localhost:${CHECK_PORT:-4011}"

WORK="$(mktemp -d)"
LOGS="$WORK/logs"
SERVICE_PID=""
trap '[[ -n "$SERVICE_PID" ]] && kill "$SERVICE_PID" 2>/dev/null; rm -rf "$WORK"' EXIT
mkdir "$LOGS"
cp -R "$RUN_DIR" "$WORK/run" || exit 1
cd "$WORK/run" || exit 1

BUGS=(equal-dates wrong-field guests-upper)
likely_cause() {
  case "$1" in
    equal-dates)  echo "missing case: checkOut = checkIn (or that test doesn't assert the rejection)" ;;
    wrong-field)  echo "weak assertion: errors[].field not checked exactly" ;;
    guests-upper) echo "missing boundary case: guests = 9 (e.g. a guessed limit such as 10 or 20)" ;;
  esac
}

# run_bookings <bug|""> <log> — starts the service with that bug, runs the booking specs, stops it.
run_bookings() {
  local code
  MOCK_BUG="$1" MOCK_PORT="${URL##*:}" node "$SERVICE" > "$LOGS/service.log" 2>&1 &
  SERVICE_PID=$!
  wait_for_health "$URL" || { cat "$LOGS/service.log" >&2; exit 1; }
  FORCE_COLOR=0 BOOKINGS_API_URL="$URL" npx playwright test tests/api/bookings --reporter=list \
    --output="$WORK/test-results" > "$2" 2>&1
  code=$?
  kill "$SERVICE_PID" 2>/dev/null; wait "$SERVICE_PID" 2>/dev/null; SERVICE_PID=""
  return $code
}

# summary <log> → e.g. "5 passed,1 failed"
summary() {
  grep -E "^[[:space:]]+[0-9]+ (passed|failed|flaky|skipped|did not run)" "$1" \
    | sed -E 's/^[[:space:]]+//; s/ \([^)]*\)$//' | paste -sd ',' -
}

# The agent's changes, including new files (intent-to-add, in the copy only); transcripts excluded.
git add -A -N .
NOT_CODE=(':(exclude)_transcript')
git diff HEAD -- . "${NOT_CODE[@]}" > "$EVIDENCE/agent.diff"

{
  echo "# Automated checks — $ID"
  echo
  echo "Baseline: scenario \`$(meta_value "$ID" scenario)\` · condition \`$(meta_value "$ID" condition)\` · commit \`$SHA\`"
  echo

  echo "## 1. Files changed by the agent (full diff: agent.diff)"
  echo '```'
  git diff --stat HEAD -- . "${NOT_CODE[@]}"
  echo '```'
  echo

  echo "## 2. Type check"
  if npm run -s typecheck > "$LOGS/typecheck.log" 2>&1; then echo "PASS"; else
    echo "FAIL"; echo '```'; tail -20 "$LOGS/typecheck.log"; echo '```'; fi
  echo

  echo "## 3. Booking tests vs. correct service (expected: all pass)"
  if run_bookings "" "$LOGS/correct.log"; then
    echo "PASS — $(summary "$LOGS/correct.log")"
  else
    echo "FAIL — $(summary "$LOGS/correct.log")"
    echo
    echo "> Tests fail against the correct service: likely an incorrect expected value (e.g. an"
    echo "> invented rule) or framework misuse. Bug detection below is not meaningful."
    echo '```'; grep -E "✘|Error:|Expected|Received" "$LOGS/correct.log" | head -30; echo '```'
  fi
  echo

  echo "## 4. Injected bugs (expected: every bug caught = at least one test fails)"
  echo
  echo "| Bug | Caught? | Result | Likely cause if missed (verify in the diff) |"
  echo "|---|---|---|---|"
  CAUGHT=0
  for bug in "${BUGS[@]}"; do
    if run_bookings "$bug" "$LOGS/$bug.log"; then
      echo "| \`$bug\` | ❌ missed | $(summary "$LOGS/$bug.log") | $(likely_cause "$bug") |"
    else
      echo "| \`$bug\` | ✅ caught | $(summary "$LOGS/$bug.log") | — |"
      CAUGHT=$((CAUGHT + 1))
    fi
  done
  echo
  echo "**Bugs caught: $CAUGHT / ${#BUGS[@]}**"
  echo

  echo "## 5. Static checks on the agent's changes"
  CHANGED=$(git diff --name-only HEAD -- '*.ts' "${NOT_CODE[@]}")
  if [[ -z "$CHANGED" ]]; then
    echo "No .ts files changed."
  else
    check() { # label, regex
      local hits
      hits=$(echo "$CHANGED" | xargs grep -nE "$2" 2>/dev/null)
      if [[ -n "$hits" ]]; then echo "- ⚠️ $1"; echo '```'; echo "$hits"; echo '```'; else echo "- ✅ No $1"; fi
    }
    check "hard waits / timeouts / retries / skips" "waitForTimeout|setTimeout|retries|test\.(skip|only|fixme)|timeout:"
    check "raw HTTP calls (framework bypass)" "request\.(post|get|put|patch|delete)\("
    check "imports from @playwright/test in specs (should use src/fixtures)" "from '@playwright/test'"
    check "hand-written booking payloads (should use aBooking())" "checkIn: *'[0-9]{4}-"
  fi
  echo
  echo "Protected files touched (playwright.config.ts, src/support/):"
  PROTECTED=$(git diff --name-only HEAD -- playwright.config.ts src/support)
  if [[ -n "$PROTECTED" ]]; then echo "⚠️ $PROTECTED"; else echo "✅ none"; fi
} > "$EVIDENCE/check-results.md"

cat "$EVIDENCE/check-results.md"
