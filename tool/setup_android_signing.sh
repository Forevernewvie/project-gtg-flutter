#!/usr/bin/env bash
set -euo pipefail

# Creates local-only Android release signing materials.
#
# Outputs (NEVER COMMIT):
# - Keystore: $HOME/.project-gtg/upload-keystore.jks
# - Gradle props: android/key.properties (gitignored by android/.gitignore)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TARGET_DIR="$HOME/.project-gtg"
KEYSTORE_PATH="$TARGET_DIR/upload-keystore.jks"
KEY_ALIAS_DEFAULT="upload"
KEY_PROPS_PATH="$ROOT_DIR/android/key.properties"

mkdir -p "$TARGET_DIR"

echo "[setup] Android release signing"
echo "[setup] Keystore: $KEYSTORE_PATH"
echo "[setup] key.properties: $KEY_PROPS_PATH"
echo

if git ls-files --error-unmatch "android/key.properties" >/dev/null 2>&1; then
  echo "[setup] ERROR: android/key.properties is tracked by git. Refusing to continue."
  echo "[setup] This file must never be committed."
  exit 1
fi

if ! git check-ignore -q "android/key.properties"; then
  echo "[setup] ERROR: android/key.properties is not ignored by git. Refusing to continue."
  echo "[setup] Ensure android/key.properties is gitignored before proceeding."
  exit 1
fi

if [[ ! -f "$KEYSTORE_PATH" ]]; then
  echo "[setup] Keystore not found. Creating a new upload keystore (interactive)."
  echo "[setup] IMPORTANT: Save your passwords safely. Do not share them."
  echo

  # Interactive by design: avoids exposing passwords on the command line.
  keytool -genkeypair -v \
    -keystore "$KEYSTORE_PATH" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS_DEFAULT"
else
  echo "[setup] Keystore already exists. Skipping keystore creation."
fi

chmod 600 "$KEYSTORE_PATH" || true

echo
echo "[setup] Writing android/key.properties (input hidden)."
read -rs -p "storePassword: " STORE_PASSWORD
echo
read -rs -p "keyPassword: " KEY_PASSWORD
echo
read -r -p "keyAlias (default: $KEY_ALIAS_DEFAULT): " KEY_ALIAS_IN
KEY_ALIAS_IN="${KEY_ALIAS_IN:-$KEY_ALIAS_DEFAULT}"

umask 077
cat >"$KEY_PROPS_PATH" <<EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS_IN
storeFile=$KEYSTORE_PATH
EOF

chmod 600 "$KEY_PROPS_PATH" || true

unset STORE_PASSWORD KEY_PASSWORD KEY_ALIAS_IN

echo
echo "[setup] OK."
echo "[setup] Next:"
echo "  ./tool/release_android.sh"
