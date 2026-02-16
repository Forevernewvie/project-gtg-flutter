#!/usr/bin/env bash
set -euo pipefail

# One-command setup for Android release prerequisites (local-only, no secrets in git).
#
# - AdMob release env: $HOME/.project-gtg/release.env
# - Android signing: $HOME/.project-gtg/upload-keystore.jks + android/key.properties

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TARGET_DIR="$HOME/.project-gtg"
RELEASE_ENV="$TARGET_DIR/release.env"
KEYSTORE_PATH="$TARGET_DIR/upload-keystore.jks"
KEY_PROPS_PATH="$ROOT_DIR/android/key.properties"

need_release_env=true
if [[ -f "$RELEASE_ENV" ]]; then
  if rg -q '^ADMOB_APP_ID_ANDROID=' "$RELEASE_ENV" && rg -q '^ADMOB_BANNER_UNIT_ID_ANDROID=' "$RELEASE_ENV"; then
    need_release_env=false
  fi
fi

need_signing=true
if [[ -f "$KEYSTORE_PATH" && -f "$KEY_PROPS_PATH" ]]; then
  need_signing=false
fi

echo "[setup] Android release prerequisites"
echo "- release.env: $RELEASE_ENV"
echo "- keystore:    $KEYSTORE_PATH"
echo "- key.props:   $KEY_PROPS_PATH"
echo

if [[ "$need_release_env" == "true" ]]; then
  echo "[setup] (1/2) AdMob release env"
  ./tool/setup_release_env.sh
else
  echo "[setup] (1/2) AdMob release env already present. Skipping."
fi

echo
if [[ "$need_signing" == "true" ]]; then
  echo "[setup] (2/2) Android signing"
  ./tool/setup_android_signing.sh
else
  echo "[setup] (2/2) Android signing already present. Skipping."
fi

echo
echo "[setup] All prerequisites look ready."
echo "[setup] Next:"
echo "  ./tool/release_android.sh"

