#!/usr/bin/env bash
# Shared helpers for the experiment scripts. Sourced, not executed.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1; DEFAULT_RUNS_DIR=/c/runs ;;
  *)                    IS_WINDOWS=0; DEFAULT_RUNS_DIR=/tmp/runs ;;
esac
export IS_WINDOWS

# RUNS_DIR: where the agent works — the only folder the agent's account can reach, one run at a time.
# EVIDENCE_DIR: run metadata, checker output and archived runs — never reachable by the agent.
RUNS_DIR="${RUNS_DIR:-$DEFAULT_RUNS_DIR}"
EVIDENCE_DIR="${EVIDENCE_DIR:-$ROOT/runs}"

# require_run_id <id> → exits unless <id> is a neutral run ID such as r01.
require_run_id() {
  [[ "$1" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "invalid run ID: '$1' (use e.g. r01)" >&2; exit 1; }
}

# meta_value <id> <key> → prints a value from $EVIDENCE_DIR/<id>/run.meta.
meta_value() {
  sed -n "s/^$2=//p" "$EVIDENCE_DIR/$1/run.meta"
}

# hash_tree <dir> → one "<sha256>  <path>" line per file, sorted, node_modules/ left out.
hash_tree() {
  local sum=(sha256sum)
  command -v sha256sum > /dev/null || sum=(shasum -a 256)
  (cd "$1" && find . -path ./node_modules -prune -o -type f -print0 | LC_ALL=C sort -z | xargs -0 "${sum[@]}")
}

# resolve_commit <ref> → prints the full SHA, or exits if it isn't a commit in this repo.
resolve_commit() {
  git -C "$ROOT" rev-parse --verify --quiet "$1^{commit}" || {
    echo "not a commit in $ROOT: $1" >&2
    exit 1
  }
}

# export_service <sha> → exports mock-api/server.mjs from that commit to
# $ROOT/.services/<sha>/ (git-ignored, outside every run folder) and prints its path.
export_service() {
  local dir="$ROOT/.services/$1"
  mkdir -p "$dir"
  git -C "$ROOT" show "$1:mock-api/server.mjs" > "$dir/server.mjs" || exit 1
  echo "$dir/server.mjs"
}

# wait_for_health <url> → waits up to ~10 s for <url>/health.
wait_for_health() {
  local _
  for _ in $(seq 1 100); do
    curl -sf "$1/health" > /dev/null 2>&1 && return 0
    sleep 0.1
  done
  echo "service did not become healthy at $1" >&2
  return 1
}
