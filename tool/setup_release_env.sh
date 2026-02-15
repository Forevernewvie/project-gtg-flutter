#!/usr/bin/env bash
set -euo pipefail

# Creates a local-only env file for release builds.
# - Path: $HOME/.project-gtg/release.env
# - This file must NEVER be committed (it's outside the repo).

TARGET_DIR="$HOME/.project-gtg"
TARGET_FILE="$TARGET_DIR/release.env"

mkdir -p "$TARGET_DIR"

echo "[setup] Creating local release env at: $TARGET_FILE"
echo "[setup] Input is hidden. Paste values carefully."

read -rs -p "AdMob App ID (Android): " ADMOB_APP_ID_ANDROID_INPUT
echo
read -rs -p "AdMob Banner Unit ID (Android): " ADMOB_BANNER_UNIT_ID_ANDROID_INPUT
echo

if [[ -z "${ADMOB_APP_ID_ANDROID_INPUT:-}" ]]; then
  echo "[setup] Missing AdMob App ID."
  exit 1
fi
if [[ -z "${ADMOB_BANNER_UNIT_ID_ANDROID_INPUT:-}" ]]; then
  echo "[setup] Missing AdMob Banner Unit ID."
  exit 1
fi

umask 077
cat >"$TARGET_FILE" <<EOF
# Local-only release env for PROJECT GTG (DO NOT COMMIT / DO NOT SHARE)
# Used by tool/release_android.sh

ADMOB_APP_ID_ANDROID=$ADMOB_APP_ID_ANDROID_INPUT
ADMOB_BANNER_UNIT_ID_ANDROID=$ADMOB_BANNER_UNIT_ID_ANDROID_INPUT
EOF

chmod 600 "$TARGET_FILE" || true

unset ADMOB_APP_ID_ANDROID_INPUT ADMOB_BANNER_UNIT_ID_ANDROID_INPUT

echo "[setup] OK. Next:"
echo "  ./tool/release_android.sh"

