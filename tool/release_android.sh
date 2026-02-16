#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

# Load local-only env (NOT in git). This avoids re-exporting variables every run.
load_env_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$path"
    set +a
  fi
}

load_env_file "$HOME/.project-gtg/release.env"
load_env_file "$ROOT_DIR/.env.local"

KEY_PROPS="$ROOT_DIR/android/key.properties"
if [[ ! -f "$KEY_PROPS" ]]; then
  echo "[release] Missing android/key.properties (gitignored)."
  echo "[release] Create it before building a release AAB."
  exit 1
fi

# Extract storeFile path without printing secrets.
STORE_FILE_PATH="$(
  rg '^storeFile=' "$KEY_PROPS" | head -n 1 | sed 's/^storeFile=//'
)"
if [[ -z "${STORE_FILE_PATH:-}" ]]; then
  echo "[release] android/key.properties is missing storeFile."
  exit 1
fi
if [[ ! -f "$STORE_FILE_PATH" ]]; then
  echo "[release] Keystore file not found at: $STORE_FILE_PATH"
  exit 1
fi

ADS_ENABLED="${ADS_ENABLED:-true}"
ADS_ENABLED_LC="$(printf '%s' "$ADS_ENABLED" | tr '[:upper:]' '[:lower:]')"
ADS_ENABLED_DART="true"
if [[ "$ADS_ENABLED_LC" == "false" || "$ADS_ENABLED_LC" == "0" ]]; then
  ADS_ENABLED_DART="false"
fi

if [[ "$ADS_ENABLED_DART" == "true" ]]; then
  # Required by Gradle manifestPlaceholders for release builds.
  if [[ -z "${ADMOB_APP_ID_ANDROID:-}" ]]; then
    echo "[release] Missing env ADMOB_APP_ID_ANDROID for AdMob release build."
    echo "[release] Example:"
    echo "  export ADMOB_APP_ID_ANDROID=\"ca-app-pub-XXXXXXXXXXXX~YYYYYYYYYY\""
    exit 1
  fi

  # Required by Dart layer (banner unit id).
  if [[ -z "${ADMOB_BANNER_UNIT_ID_ANDROID:-}" ]]; then
    echo "[release] Missing env ADMOB_BANNER_UNIT_ID_ANDROID for AdMob release build."
    echo "[release] Example:"
    echo "  export ADMOB_BANNER_UNIT_ID_ANDROID=\"ca-app-pub-XXXXXXXXXXXX/ZZZZZZZZZZ\""
    exit 1
  fi

  # Guardrails: prevent shipping Google test IDs by mistake.
  if [[ "${ADMOB_APP_ID_ANDROID}" == "ca-app-pub-3940256099942544~3347511713" ]]; then
    echo "[release] Refusing to build with Google's TEST AdMob App ID."
    exit 1
  fi
  if [[ "${ADMOB_BANNER_UNIT_ID_ANDROID}" == "ca-app-pub-3940256099942544/6300978111" ]]; then
    echo "[release] Refusing to build with Google's TEST Banner Ad Unit ID."
    exit 1
  fi
fi

PRIVACY_POLICY_URL_VALUE="${PRIVACY_POLICY_URL:-}"

echo "[release] flutter clean"
flutter clean >/dev/null

echo "[release] flutter pub get"
flutter pub get >/dev/null

echo "[release] build appbundle (release)"
ARGS=(
  "build"
  "appbundle"
  "--release"
  "--dart-define=ADS_ENABLED=$ADS_ENABLED_DART"
)

if [[ "$ADS_ENABLED_DART" == "true" ]]; then
  ARGS+=("--dart-define=ADMOB_BANNER_AD_UNIT_ID_ANDROID=$ADMOB_BANNER_UNIT_ID_ANDROID")
fi

if [[ -n "$PRIVACY_POLICY_URL_VALUE" ]]; then
  ARGS+=("--dart-define=PRIVACY_POLICY_URL=$PRIVACY_POLICY_URL_VALUE")
fi

flutter "${ARGS[@]}" >/dev/null

AAB_PATH="$ROOT_DIR/build/app/outputs/bundle/release/app-release.aab"
if [[ ! -f "$AAB_PATH" ]]; then
  echo "[release] AAB not found at expected path: $AAB_PATH"
  exit 1
fi

echo "[release] OK: $AAB_PATH"
