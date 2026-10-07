#!/usr/bin/env bash
#
# add-movie.sh — rename an encoded movie, ship it to the Jellyfin server,
# and trigger a library scan so it shows up without manual intervention.
#
# USAGE:
#   ./add-movie.sh "/path/to/HandBrake/output.mkv"
#   ./add-movie.sh "/path/to/HandBrake/output.mkv" "The Matrix" 1999
#
# You'll be prompted for the title/year if you don't pass them as args.

set -euo pipefail

# ---------- CONFIG — edit these once for your setup ----------

# SSH host for your Jellyfin server (use your Tailscale hostname/IP,
# e.g. "anton" if that's in your SSH config, or the tailnet IP directly)
JELLYFIN_HOST="anton"

# Path on the server that's mounted into the Jellyfin container as /media/movies
REMOTE_MOVIES_DIR="/home/travis/media/movies"     # <-- update to your real host path

# Jellyfin API details (Dashboard -> API Keys -> create one)
JELLYFIN_URL="http://anton:8096"
# Kept out of the repo: set JELLYFIN_API_KEY in your env, or put it in
# ~/.config/jellyfin/api_key (chmod 600).
JELLYFIN_API_KEY="${JELLYFIN_API_KEY:-}"
if [[ -z "$JELLYFIN_API_KEY" && -f "$HOME/.config/jellyfin/api_key" ]]; then
  JELLYFIN_API_KEY="$(<"$HOME/.config/jellyfin/api_key")"
fi
if [[ -z "$JELLYFIN_API_KEY" ]]; then
  echo "JELLYFIN_API_KEY not set (env or ~/.config/jellyfin/api_key)" >&2
  exit 1
fi

# ---------------------------------------------------------------

SRC_FILE="${1:?Usage: add-movie.sh <path-to-mkv> [\"Title\"] [year]}"
TITLE="${2:-}"
YEAR="${3:-}"

if [[ ! -f "$SRC_FILE" ]]; then
  echo "File not found: $SRC_FILE" >&2
  exit 1
fi

if [[ -z "$TITLE" ]]; then
  read -rp "Movie title: " TITLE
fi
if [[ -z "$YEAR" ]]; then
  read -rp "Year: " YEAR
fi

# Build the Jellyfin-friendly filename: "Title (Year).mkv"
CLEAN_NAME="${TITLE} (${YEAR}).mkv"

echo "==> Renaming to: $CLEAN_NAME"
TMP_PATH="$(dirname "$SRC_FILE")/$CLEAN_NAME"
mv "$SRC_FILE" "$TMP_PATH"

echo "==> Copying to ${JELLYFIN_HOST}:${REMOTE_MOVIES_DIR}/"
rsync -avh --progress "$TMP_PATH" "${JELLYFIN_HOST}:${REMOTE_MOVIES_DIR}/"

echo "==> Triggering Jellyfin library scan"
curl -s -X POST \
  -H "Authorization: MediaBrowser Token=\"${JELLYFIN_API_KEY}\"" \
  "${JELLYFIN_URL}/Library/Refresh" \
  && echo "Scan triggered." \
  || echo "Scan trigger failed — check API key/URL."

echo "==> Done. \"${TITLE} (${YEAR})\" should appear in Jellyfin shortly."
