#!/usr/bin/env bash
# Creates a fresh, isolated copy of the project for ONE agent run, exported from a pinned commit.
#
#   experiments/scripts/prepare-run.sh <scenario> <condition> <commit> <run-id>
#
# Scenarios and conditions:
#   main                   no-context | persistent | full
#       Same requirements everywhere: docs/tickets/BOOK-412.md is in every run.
#       Only the project context and the task-instruction structure vary.
#   missing-requirements   no-context | persistent
#       docs/tickets/BOOK-412.md and .ai/tasks/ are removed. Success = asking for the rules,
#       not inventing them.
#
# Conditions:
#   no-context   AGENTS.md, CLAUDE.md, .github/copilot-instructions.md and .ai/ removed
#   persistent   .ai/tasks/ removed
#   full         everything kept
#
# The run folder is $RUNS_DIR/<run-id> (default C:\runs on Windows). Use neutral IDs (r01, r02, …):
# nothing in the run folder — its name, files or git history — reveals the scenario or condition.
# That mapping is written to $EVIDENCE_DIR/<run-id>/run.meta, outside the agent's reach.
#
# Never copied into a run: experiments/ and mock-api/. The service runs separately
# (start-service.sh), so a run folder contains neither the service code nor its location.
# Refuses to start while $RUNS_DIR holds another run: archive it first (archive-run.sh).
set -euo pipefail
source "$(dirname "$0")/lib.sh"

usage() { echo "usage: $0 <main|missing-requirements> <no-context|persistent|full> <commit> <run-id>" >&2; exit 1; }
SCENARIO="${1:-}"; CONDITION="${2:-}"; REF="${3:-}"; ID="${4:-}"
[[ -n "$SCENARIO" && -n "$CONDITION" && -n "$REF" && -n "$ID" ]] || usage

case "$SCENARIO:$CONDITION" in
  main:no-context|main:persistent|main:full) ;;
  missing-requirements:no-context|missing-requirements:persistent) ;;
  missing-requirements:full) echo "'full' includes the requirements, so it doesn't apply to missing-requirements" >&2; exit 1 ;;
  *) usage ;;
esac

require_run_id "$ID"
SHA="$(resolve_commit "$REF")"

mkdir -p "$RUNS_DIR"
RUNS_DIR="$(cd "$RUNS_DIR" && pwd)"
case "$RUNS_DIR/" in
  "$ROOT"/*) echo "RUNS_DIR must be outside $ROOT" >&2; exit 1 ;;
esac
if [[ -n "$(ls -A "$RUNS_DIR")" ]]; then
  echo "$RUNS_DIR is not empty — archive the previous run first (archive-run.sh):" >&2
  ls -A "$RUNS_DIR" >&2
  exit 1
fi
EVIDENCE="$EVIDENCE_DIR/$ID"
if [[ -e "$EVIDENCE" ]]; then echo "run ID already used: $EVIDENCE exists" >&2; exit 1; fi
TARGET="$RUNS_DIR/$ID"
mkdir -p "$TARGET" "$EVIDENCE"

# 1. Export the pinned commit — never the working tree. LF line endings, whatever your git settings.
git -C "$ROOT" -c core.autocrlf=false archive "$SHA" | tar -x -C "$TARGET"
cd "$TARGET"
mv experiments/project-README.md README.md
rm -rf experiments mock-api LICENSE
grep -vxE 'runs/|\.services/' .gitignore > .gitignore.tmp && mv .gitignore.tmp .gitignore

# 2. Scenario.
if [[ "$SCENARIO" == "missing-requirements" ]]; then
  rm -f docs/tickets/BOOK-412.md
  rm -rf .ai/tasks
fi

# 3. Condition.
case "$CONDITION" in
  no-context) rm -rf AGENTS.md CLAUDE.md .ai .github/copilot-instructions.md
              rmdir .github 2>/dev/null || true ;;
  persistent) rm -rf .ai/tasks ;;
  full)       ;;
esac

# 4. A neutral initial commit. The repo's own core.autocrlf=false overrides the global setting of
#    whichever account opens it, so git status starts clean for the agent too. Then dependencies.
git init -q -b main
git config core.autocrlf false
git add -A
git -c user.name="Bookings Team" -c user.email="team@bookings.example" -c commit.gpgsign=false \
  commit -qm "Initial commit"
npm ci --no-audit --no-fund --silent

cat > "$EVIDENCE/run.meta" <<EOF
id=$ID
scenario=$SCENARIO
condition=$CONDITION
commit=$SHA
prepared=$(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo
echo "Ready: $TARGET"
echo "Scenario: $SCENARIO · condition: $CONDITION · commit: ${SHA:0:12}"
echo
echo "1. In another terminal, start the service from the same commit:"
echo "     $ROOT/experiments/scripts/start-service.sh $SHA"
echo "2. Open a NEW agent session in the run folder and send exactly this prompt:"
echo
if [[ "$CONDITION" == "full" ]]; then
  echo "     Read AGENTS.md, then execute .ai/tasks/BOOK-412-booking-validation.md"
elif [[ "$SCENARIO" == "main" ]]; then
  echo "     Add negative tests for POST /bookings validation. The requirements are in docs/tickets/BOOK-412.md."
else
  echo "     Add negative tests for POST /bookings validation."
fi
echo
echo "3. When the agent is done: copy its transcripts into $TARGET/_transcript/, then"
echo "     $ROOT/experiments/scripts/check-run.sh $ID"
echo "     $ROOT/experiments/scripts/archive-run.sh $ID"
