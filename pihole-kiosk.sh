#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8088}"
DOCROOT="${DOCROOT:-/opt/pihole-kiosk}"
URL="${URL:-http://127.0.0.1:${PORT}/}"

# Prevent screen blanking (requires X)
if command -v xset >/dev/null 2>&1; then
  xset s off || true
  xset -dpms || true
  xset s noblank || true
fi

# Get IPv4 address without assuming interface name.
IP="$(ip -4 route get 1.1.1.1 2>/dev/null | awk '/src/ {for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}' || true)"
if [[ -z "${IP}" ]]; then
  IP="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
fi
echo "${IP:-unknown}" > "${DOCROOT}/ip.txt"

# Local webserver for dashboard (needed so the page has an http:// origin)
cd "${DOCROOT}"
python3 -m http.server "${PORT}" --bind 127.0.0.1 &
SERVER_PID=$!
trap 'kill ${SERVER_PID} 2>/dev/null || true' EXIT INT TERM

sleep 0.3

# Launch Chromium in kiosk mode
/usr/lib/chromium/chromium \
  --kiosk \
  --incognito \
  --noerrdialogs \
  --disable-infobars \
  --overscroll-history-navigation=0 \
  --disable-gpu \
  --disable-gpu-compositing \
  --use-gl=swiftshader \
  "${URL}" &
wait $!
