#!/usr/bin/env bash
# devbox entry hook — runs in the guest, fed to `bash -lc` by the `devbox` script
# on shell / claude / vibe / run ($1 = nearest project dir, or empty). Runs, once
# per VM boot: ~/.devbox-rc/runtime.sh, then the nearest .devbox.sh. Markers live
# in /dev/shm (cleared on boot); a failed script isn't retried until next boot.
set -u

rc="$HOME/.devbox-rc"
if [ -f "$rc/runtime.sh" ] && [ ! -e /dev/shm/.devbox-runtime-done ]; then
  : > /dev/shm/.devbox-runtime-done
  bash "$rc/runtime.sh" || echo "devbox: ~/.devbox/rc/runtime.sh exited $?" >&2
fi

proj=${1:-}
if [ -n "$proj" ] && [ -f "$proj/.devbox.sh" ]; then
  marker="/dev/shm/.devbox-proj-$(printf %s "$proj" | sha256sum | cut -c1-16)"
  if [ ! -e "$marker" ]; then
    : > "$marker"
    ( cd "$proj" && exec bash .devbox.sh ) || echo "devbox: $proj/.devbox.sh exited $?" >&2
  fi
fi
