#!/bin/sh
# Builds Snap and its MCP server, and runs the desktop features on X11 or on Wayland:
#   snap-acceptance <x11|wayland> [axx run arguments]
# The sources are read from /src (the repository, mounted read-only), the build is made in a
# copy, and axx is the one on PATH (mounted). With /out mounted, the traces and videos axx kept,
# and the screenshots the run took that the repository has none of, are copied there, readable
# outside the container.
set -eu
display=$1
shift
mkdir -p /work/snap
rsync -a --delete --exclude node_modules --exclude target --exclude .venv --exclude .axx /src/ /work/snap/
cd /work/snap
(cd app && npm ci --no-audit --no-fund > /dev/null && npx tauri build --no-bundle)
python3 -m venv mcp-server/.venv
mcp-server/.venv/bin/pip install --quiet -e mcp-server
profile=desktop-linux
if [ "$display" = wayland ]; then
  # GNOME Shell needs a system bus; without logind (as in a container), no /run/systemd/seats.
  mkdir -p /run/dbus
  dbus-daemon --system --fork
  profile=$profile,wayland
fi
status=0
axx run --profile "$profile" "$@" || status=$?
if [ -d /out ]; then
  # A run takes a screenshot the repository has none of, and fails: those it took, to add.
  (cd acceptance/screenshots && find . -type f -name '*.png') | while IFS= read -r f; do
    if ! cmp -s "acceptance/screenshots/$f" "/src/acceptance/screenshots/$f"; then
      mkdir -p "/out/screenshots/$(dirname "$f")"
      cp "acceptance/screenshots/$f" "/out/screenshots/$f"
    fi
  done
  # The traces and videos axx kept, readable outside the container.
  cp -R .axx/desktop/traces .axx/desktop/videos /out/ 2> /dev/null || true
  chmod -R a+rX /out
fi
exit $status
