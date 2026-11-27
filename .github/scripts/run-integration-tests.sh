#!/usr/bin/env bash
# Runs each integration test file on an iOS simulator, one file at a time,
# under a watchdog.
#
# On hosted macOS runners `flutter test` often hangs right after
# "Xcode build done.": the app launches, but the tool never reads the Dart VM
# service address from the simulator's log stream, and it waits for it with
# no timeout. The watchdog stops a file that
#   - hasn't started its first test LAUNCH_TIMEOUT seconds after the build
#     (healthy runs start within a minute), or
#   - prints nothing for IDLE_TIMEOUT seconds at any point (the longest quiet
#     stretch in a healthy run is about 4 minutes: a cold Xcode build),
# and then, as for a failed file, reboots the simulator and runs that file
# again, up to MAX_ATTEMPTS times.
#
# Usage, from example/:
#   DEVICE_ID=<simulator udid> ../.github/scripts/run-integration-tests.sh [test file...]
# With no files, runs integration_test/*_test.dart.
set -uo pipefail

: "${DEVICE_ID:?set DEVICE_ID to a booted simulator UDID}"
IDLE_TIMEOUT=${IDLE_TIMEOUT:-360}
LAUNCH_TIMEOUT=${LAUNCH_TIMEOUT:-180}
MAX_ATTEMPTS=${MAX_ATTEMPTS:-3}

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

# True once the app is built but no test has started: the expanded reporter
# prints "MM:SS +N: <test name>" for each test, and "... loading <file>"
# before the build.
waiting_for_app() {
  grep -q 'Xcode build done' "$log" &&
    ! awk '/^[0-9]+:[0-9]+ \+[0-9]+/ && !/: loading / { found = 1 }
           END { exit !found }' "$log"
}

# Runs one test file and returns its exit status, or 124 if the watchdog
# stopped it (with the reason in $stall_reason).
run_file() {
  local pid tail_pid idle status=0
  stall_reason=
  : >"$log"
  flutter test "$1" -d "$DEVICE_ID" --reporter expanded >"$log" 2>&1 &
  pid=$!
  tail -n +1 -f "$log" &
  tail_pid=$!

  while kill -0 "$pid" 2>/dev/null; do
    sleep 5
    idle=$(($(date +%s) - $(stat -f %m "$log")))
    if [ "$idle" -ge "$LAUNCH_TIMEOUT" ] && waiting_for_app; then
      stall_reason="started no test ${LAUNCH_TIMEOUT}s after the app was built"
    elif [ "$idle" -ge "$IDLE_TIMEOUT" ]; then
      stall_reason="printed nothing for ${IDLE_TIMEOUT}s"
    fi
    if [ -n "$stall_reason" ]; then
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

  if [ -n "$stall_reason" ]; then
    echo "Watchdog: $stall_reason, stopped flutter test."
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
      reason=$stall_reason
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
