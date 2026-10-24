#!/usr/bin/env bash
# Moves one finished, checked run out of the agent's reach, so the next run can't see it.
#
#   experiments/scripts/archive-run.sh <run-id>
#
# Copies $RUNS_DIR/<run-id> (without node_modules/) to $EVIDENCE_DIR/<run-id>/workspace/, then
# verifies the copy before deleting the original:
#   1. _transcript/ exists in the run folder and check-run.sh has written its results
#   2. the copy's file hashes match the original's
#   3. (Windows) after `icacls /reset`, every permission entry — inherited or explicit — on the
#      evidence folder belongs to SYSTEM, Administrators or you. Anything else fails, by SID, so
#      group names in other display languages don't matter.
# A copy, not a move: a move within the same drive keeps C:\runs' permissions, agent account included.
set -euo pipefail
source "$(dirname "$0")/lib.sh"

ID="${1:-}"
[[ -n "$ID" ]] || { echo "usage: $0 <run-id>" >&2; exit 1; }
require_run_id "$ID"
RUN_DIR="$RUNS_DIR/$ID"
EVIDENCE="$EVIDENCE_DIR/$ID"
DEST="$EVIDENCE/workspace"

[[ -d "$RUN_DIR" ]] || { echo "no run folder at $RUN_DIR" >&2; exit 1; }
[[ -n "$(ls -A "$RUN_DIR/_transcript" 2>/dev/null)" ]] || {
  echo "$RUN_DIR/_transcript/ is missing or empty — copy the session transcripts there first" >&2; exit 1; }
[[ -f "$EVIDENCE/check-results.md" ]] || { echo "run check-run.sh $ID first" >&2; exit 1; }
[[ ! -e "$DEST" ]] || { echo "already archived: $DEST exists" >&2; exit 1; }

# 1. Copy.
mkdir "$DEST"
(cd "$RUN_DIR" && tar -cf - --exclude=./node_modules .) | (cd "$DEST" && tar -xf -)

# 2. Permissions: only you (and the system) may read the evidence.
if [[ "$IS_WINDOWS" == 1 ]]; then
  MSYS_NO_PATHCONV=1 icacls "$(cygpath -w "$DEST")" /reset /T /C /Q > /dev/null   # keep /reset literal
  # shellcheck disable=SC2016 # the $ below is PowerShell's, not bash's
  if ! EVIDENCE_PATH="$(cygpath -w "$EVIDENCE")" powershell.exe -NoProfile -NonInteractive -Command '
    $ErrorActionPreference = "Stop"
    $me = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $allowed = @("S-1-5-18", "S-1-5-32-544", $me)   # SYSTEM, Administrators, you
    $items = @(Get-Item -LiteralPath $env:EVIDENCE_PATH -Force) + @(Get-ChildItem -LiteralPath $env:EVIDENCE_PATH -Recurse -Force)
    $bad = foreach ($item in $items) {
      foreach ($rule in (Get-Acl -LiteralPath $item.FullName).Access) {
        $sid = $rule.IdentityReference.Translate([Security.Principal.SecurityIdentifier]).Value
        if ($allowed -notcontains $sid) { "$($item.FullName): $($rule.IdentityReference) ($sid)" }
      }
    }
    if ($bad) { $bad | Select-Object -First 20; exit 1 }'; then
    echo "❌ permission check failed: the entries above are not allowed. Original kept in $RUN_DIR" >&2
    exit 1
  fi
else
  chmod -R go= "$EVIDENCE"
fi

# 3. Contents.
if ! diff <(hash_tree "$RUN_DIR") <(hash_tree "$DEST") > /dev/null; then
  echo "❌ the copy doesn't match the original. Original kept in $RUN_DIR" >&2
  exit 1
fi

# 4. Only now delete the original.
rm -rf "$RUN_DIR"
echo "✅ $ID archived to $DEST ($(hash_tree "$DEST" | wc -l | tr -d ' ') files verified, permissions checked)."
echo "   $RUNS_DIR is empty again. Clear the agent account's session data before the next run."
