#!/bin/sh

RUNNER="$1"
READY="/var/mobile/Library/Preferences/com.burc334.nightnight.sleepd.ready"

export NIGHTNIGHT_READY_SIGNAL=1
rm -f "$READY"
trap 'printf "pid=%d\n" "$$" > "$READY" 2>/dev/null || true' USR1

"$RUNNER" --daemon &
child=$!

while :; do
    wait "$child"
    status=$?
    kill -0 "$child" 2>/dev/null || break
done

rm -f "$READY"
exit "$status"
