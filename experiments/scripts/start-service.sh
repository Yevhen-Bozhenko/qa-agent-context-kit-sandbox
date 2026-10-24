#!/usr/bin/env bash
# Runs the Bookings service (the mock, WITHOUT injected bugs) exported from a pinned commit.
# Keep it running in its own terminal while an agent works in a run folder.
#
#   experiments/scripts/start-service.sh <commit> [port]     (default port 4010)
set -euo pipefail
source "$(dirname "$0")/lib.sh"

[[ -n "${1:-}" ]] || { echo "usage: $0 <commit> [port]" >&2; exit 1; }
SHA="$(resolve_commit "$1")"
PORT="${2:-4010}"
SERVICE="$(export_service "$SHA")"

echo "Bookings service from commit ${SHA:0:12} on http://localhost:$PORT (Ctrl+C to stop)"
exec env -u MOCK_BUG MOCK_PORT="$PORT" node "$SERVICE"
