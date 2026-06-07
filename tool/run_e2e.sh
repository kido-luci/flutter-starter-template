#!/usr/bin/env bash
# Runs the real-backend end-to-end suite (integration_test/e2e_test.dart) in
# one shot: resets the local backend's database, starts it fresh, waits for
# it to come up, runs the suite against a connected iOS Simulator, then tears
# the backend down.
#
# Usage: tool/run_e2e.sh [device-id]
#   device-id  Optional `flutter devices` id of the iOS Simulator to target.
#              Defaults to the first iOS simulator `flutter devices` reports.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backend_dir="$repo_root/simple_backend_server"
backend_addr="${ADDR:-:8080}"
backend_url="http://localhost${backend_addr}"

device_id="${1:-}"
if [[ -z "$device_id" ]]; then
  device_id="$(
    cd "$repo_root" &&
      fvm flutter devices --machine 2>/dev/null |
      python3 -c '
import json, sys
devices = json.load(sys.stdin)
for d in devices:
    if d.get("targetPlatform", "").startswith("ios") and d.get("emulator"):
        print(d["id"])
        break
'
  )"
fi
if [[ -z "$device_id" ]]; then
  echo "No iOS Simulator found. Boot one (open -a Simulator) and retry, or" >&2
  echo "pass its 'flutter devices' id explicitly: tool/run_e2e.sh <device-id>" >&2
  exit 1
fi
echo "Targeting device: $device_id"

backend_port="${backend_addr#:}"
stale_pids="$(lsof -ti ":$backend_port" 2>/dev/null || true)"
if [[ -n "$stale_pids" ]]; then
  echo "Killing stale process(es) on port $backend_port: $stale_pids"
  # `go run` execs a cached binary as a child — a plain `kill` on the wrapper
  # can leave that child holding the port across runs (it did once during
  # development, serving stale data and silently masking a bind failure).
  # -9 the actual listener(s) directly so the port is reliably free.
  kill -9 $stale_pids 2>/dev/null || true
  sleep 1
fi

echo "Resetting backend database ($backend_dir/data.db)…"
rm -f "$backend_dir/data.db"

echo "Starting backend ($backend_url)…"
(cd "$backend_dir" && ADDR="$backend_addr" go run .) &
backend_pid=$!
trap '
  echo "Stopping backend (pid $backend_pid)…"
  kill "$backend_pid" 2>/dev/null || true
  wait "$backend_pid" 2>/dev/null || true
  remaining="$(lsof -ti ":$backend_port" 2>/dev/null || true)"
  [[ -n "$remaining" ]] && kill -9 $remaining 2>/dev/null || true
' EXIT

echo "Waiting for backend to come up…"
for _ in $(seq 1 30); do
  if curl -fsS "$backend_url/health" >/dev/null 2>&1; then
    echo "Backend is up."
    break
  fi
  sleep 1
done
if ! curl -fsS "$backend_url/health" >/dev/null 2>&1; then
  echo "Backend did not respond at $backend_url/health within 30s." >&2
  exit 1
fi

echo "Running integration_test/e2e_test.dart…"
cd "$repo_root"
fvm flutter test integration_test/e2e_test.dart \
  -d "$device_id" \
  --dart-define=API_BASE_URL="$backend_url" \
  --dart-define=FLAVOR=dev
