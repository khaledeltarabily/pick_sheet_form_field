#!/usr/bin/env bash
# Runs each integration test file on an iOS simulator, one file at a time,
# under a watchdog.
#
# On hosted macOS runners `flutter test` often hangs right after
# "Xcode build done.": the app launches, but the tool never reads the Dart VM
# service address from the simulator's log stream, and it waits for it with
# no timeout. (The app is launched with --disable-vm-service-publication, so
# the log is the only way the tool finds it.)
#
# If no test has started LAUNCH_TIMEOUT seconds after the build (healthy runs
# start within a minute), the watchdog prints what it can see (is the app
# running, is the tool's log stream running, did the app log its VM service
# address) and relaunches only the app with the same arguments: the tool is
# still reading the log, matches the app by name, and takes the first address
# it sees. If that doesn't help within another LAUNCH_TIMEOUT, or the file
# prints nothing for IDLE_TIMEOUT seconds at any point (the longest quiet
# stretch in a healthy run is about 4 minutes: a cold Xcode build), the
# watchdog stops the file and, as for a failed file, reboots the simulator and
# runs it again, up to MAX_ATTEMPTS times.
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

# The test app's process on this simulator, as "<binary> <arguments>".
app_process() {
  pgrep -lf "/Devices/$DEVICE_ID/.*/Runner\.app/Runner( |$)" |
    head -n 1 | cut -d ' ' -f 2-
}

diagnose_launch() {
  echo "Watchdog: app process: $(app_process | cut -c1-300)"
  echo "Watchdog: flutter's log stream: $(pgrep -fl 'log stream --style json' | cut -c1-120 | tr '\n' ';')"
  echo "Watchdog: VM service lines in the simulator log, last 10 minutes:"
  xcrun simctl spawn "$DEVICE_ID" log show --last 10m --info --debug \
    --style compact --predicate 'eventMessage CONTAINS[c] "VM service"' 2>&1 |
    tail -n 5
}

# Relaunches the app with the arguments flutter launched it with.
relaunch_app() {
  local proc binary args bundle
  bundle=$(plutil -extract CFBundleIdentifier raw \
    build/ios/iphonesimulator/Runner.app/Info.plist)
  proc=$(app_process)
  if [ -n "$proc" ]; then
    binary=${proc%% -*}
    args=${proc#"$binary"}
  else
    # What flutter test passes, in case the app isn't running.
    args='--enable-dart-profiling --disable-vm-service-publication --enable-checked-mode --verify-entry-points'
  fi
  xcrun simctl terminate "$DEVICE_ID" "$bundle" >/dev/null 2>&1 || true
  # shellcheck disable=SC2086 # $args holds separate flags
  xcrun simctl launch "$DEVICE_ID" "$bundle" $args
}

# Runs one test file and returns its exit status, or 124 if the watchdog
# stopped it (with the reason in $stall_reason).
run_file() {
  local pid tail_pid idle status=0 relaunched=0
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
      diagnose_launch
      # The tests may have started while the diagnostics ran.
      waiting_for_app || continue
      if [ "$relaunched" -eq 0 ]; then
        relaunched=1
        echo "::warning title=Integration test app relaunched::$1 started no test ${LAUNCH_TIMEOUT}s after the app was built; relaunched the app."
        relaunch_app
        touch "$log"
        continue
      fi
      stall_reason="started no test ${LAUNCH_TIMEOUT}s after the app was built, nor after relaunching it"
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
