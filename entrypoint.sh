#!/bin/sh
set -u

cd /opt/telegram-mcp

if [ -z "${MCP_AUTH_TOKEN:-}" ]; then
  echo "MCP_AUTH_TOKEN is required" >&2
  exit 1
fi

export MCP_TRANSPORT=http
export MCP_HOST=127.0.0.1
export MCP_PORT=8765
export PORT="${PORT:-8080}"
export TELEGRAM_TRANSCRIPT_CACHE_DIR="${TELEGRAM_TRANSCRIPT_CACHE_DIR:-/data/transcripts}"

mkdir -p /tmp/caddy-config /tmp/caddy-data
mkdir -p "$TELEGRAM_TRANSCRIPT_CACHE_DIR" 2>/dev/null || \
  echo "Transcript cache directory is not writable; continuing without it." >&2

session_present=0
if [ -n "${TELEGRAM_SESSION_STRING:-}" ] || [ -n "${TELEGRAM_SESSION_STRINGS:-}" ]; then
  session_present=1
fi

if [ -n "${TELEGRAM_API_ID:-}" ] && [ -n "${TELEGRAM_API_HASH:-}" ] && [ "$session_present" -eq 1 ]; then
  echo "Starting telegram-mcp" >&2
  python main.py &
else
  echo "Telegram session is not configured yet. /mcp will answer 503 until TELEGRAM_API_ID, TELEGRAM_API_HASH and TELEGRAM_SESSION_STRING are set." >&2
  python /opt/railway/stub.py &
fi
child=$!

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
caddy_pid=$!

term() {
  kill "$child" "$caddy_pid" 2>/dev/null || true
  wait "$child" 2>/dev/null || true
  wait "$caddy_pid" 2>/dev/null || true
}
trap term INT TERM

while kill -0 "$child" 2>/dev/null && kill -0 "$caddy_pid" 2>/dev/null; do
  sleep 2
done

echo "A process exited; shutting down" >&2
term
exit 1
