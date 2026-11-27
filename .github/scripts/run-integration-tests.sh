#!/usr/bin/env bash
# Runs each integration test file on an iOS simulator, one file at a time,
# under a watchdog.
#
# On hosted macOS runners `flutter test` sometimes hangs right after
# "Xcode build done.": the app launches, but the tool never finds its Dart VM
# service and waits forever. If a file prints nothing for IDLE_TIMEOUT seconds
# (or fails), the watchdog stops it, reboots the simulator and runs that file
# again, up to MAX_ATTEMPTS times. The longest quiet stretch in a healthy run
# is about 2.5 minutes (a cold Xcode build, or the 100k-item stress test).
#
# Usage, from example/:
#   DEVICE_ID=<simulator udid> ../.github/scripts/run-integration-tests.sh [test file...]
# With no files, runs integration_test/*_test.dart.
set -uo pipefail

: "${DEVICE_ID:?set DEVICE_ID to a booted simulator UDID}"
IDLE_TIMEOUT=${IDLE_TIMEOUT:-300}
MAX_ATTEMPTS=${MAX_ATTEMPTS:-2}

if [ $# -eq 0 ]; then
  set -- integration_test/*_test.dart
fi

# Give each background job its own process group, so the watchdog can stop
# flutter together with the dart and xcrun processes it starts.
set -m

log=$(mktemp)
trap 'rm -f "$log"' EXIT

reboot_simulator() {
  xcrun simctl shutdown "$DEVICE_ID" >/dev/null 2>&1 || true
  xcrun simctl boot "$DEVICE_ID"
  xcrun simctl bootstatus "$DEVICE_ID" >/dev/null
}

# Runs one test file and returns its exit status, or 124 if the watchdog
# stopped it.
run_file() {
  local pid tail_pid idle status=0 stalled=0
  : >"$log"
  flutter test "$1" -d "$DEVICE_ID" --reporter expanded >"$log" 2>&1 &
  pid=$!
  tail -n +1 -f "$log" &
  tail_pid=$!

  while kill -0 "$pid" 2>/dev/null; do
    sleep 5
    idle=$(($(date +%s) - $(stat -f %m "$log")))
    if [ "$idle" -ge "$IDLE_TIMEOUT" ]; then
      stalled=1
      kill -TERM -- "-$pid" 2>/dev/null
      sleep 5
      kill -KILL -- "-$pid" 2>/dev/null
      break
    fi
  done
  wait "$pid" 2>/dev/null || status=$?

  sleep 1 # let tail print the last lines
  kill "$tail_pid" 2>/dev/null
  wait "$tail_pid" 2>/dev/null

  if [ "$stalled" -eq 1 ]; then
    echo "Watchdog: no output for ${IDLE_TIMEOUT}s, stopped flutter test."
    return 124
  fi
  return "$status"
}

failed=0
for file in "$@"; do
  attempt=1
  while :; do
    echo "==> $file (attempt $attempt of $MAX_ATTEMPTS)"
    run_file "$file"
    status=$?
    [ "$status" -eq 0 ] && break

    if [ "$status" -eq 124 ]; then
      reason="printed nothing for ${IDLE_TIMEOUT}s"
    else
      reason="failed (exit $status)"
    fi
    if [ "$attempt" -ge "$MAX_ATTEMPTS" ]; then
      echo "::error title=Integration test failed::$file $reason on all $MAX_ATTEMPTS attempts."
      failed=$((failed + 1))
      break
    fi
    echo "::warning title=Integration test retried::$file $reason on attempt $attempt; rebooting the simulator and retrying."
    reboot_simulator
    attempt=$((attempt + 1))
  done
done

[ "$failed" -eq 0 ]
