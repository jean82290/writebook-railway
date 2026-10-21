#!/bin/bash
# Railway entrypoint for Writebook.
#  1. Railway mounts volumes as root but Writebook runs as uid 1000:
#     give the volume to that user, then drop root privileges.
#  2. Make sure a secret key exists, even if the variable was removed.
#  3. On first boot, create the administrator from ADMIN_EMAIL / ADMIN_PASSWORD,
#     so nobody else can claim the public first-run page.
set -euo pipefail

APP_UID=1000
STORAGE=/rails/storage
ADMIN_MARKER="$STORAGE/.railway-admin-ready"
SECRET_FILE="$STORAGE/.railway-secret-key-base"

log() { echo "[railway] $*"; }

# --- 1. Volume ownership, then drop privileges -------------------------------
if [ "$(id -u)" = "0" ]; then
  mkdir -p "$STORAGE"
  find "$STORAGE" -xdev ! -user "$APP_UID" -exec chown "$APP_UID:$APP_UID" {} +
  export HOME=/home/rails
  exec gosu "$APP_UID:$APP_UID" "$0" "$@"
fi

cd /rails

# --- 2. Secret key -----------------------------------------------------------
if [ -z "${SECRET_KEY_BASE:-}" ]; then
  if [ ! -s "$SECRET_FILE" ]; then
    log "SECRET_KEY_BASE is not set: generating one and keeping it on the volume."
    ruby -rsecurerandom -e 'print SecureRandom.hex(64)' > "$SECRET_FILE"
    chmod 600 "$SECRET_FILE"
  fi
  SECRET_KEY_BASE="$(cat "$SECRET_FILE")"
  export SECRET_KEY_BASE
fi

# --- 3. First administrator ---------------------------------------------------
if [ ! -f "$ADMIN_MARKER" ]; then
  if [ -n "${ADMIN_EMAIL:-}" ] && [ -n "${ADMIN_PASSWORD:-}" ]; then
    log "First boot: preparing the database and creating the administrator account."
    # Writebook expects Redis on localhost; run a throwaway one for this step only.
    redis-server --port 6379 --save "" --appendonly no --loglevel warning &
    redis_pid=$!
    if ./bin/rails db:prepare && ./bin/rails runner /railway/create_admin.rb; then
      touch "$ADMIN_MARKER"
    else
      log "Could not create the administrator automatically."
      log "Open the app URL to create the first account by hand, then check the logs above."
    fi
    kill "$redis_pid" 2>/dev/null || true
    wait "$redis_pid" 2>/dev/null || true
  else
    log "ADMIN_EMAIL or ADMIN_PASSWORD is empty: open the app URL now to create the first account."
  fi
fi

# Hand over to Writebook's own entrypoint and process manager (web, jobs, Redis).
exec /rails/bin/docker-entrypoint "$@"
