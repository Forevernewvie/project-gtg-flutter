#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ADB_BIN="${ADB_BIN:-$HOME/Library/Android/sdk/platform-tools/adb}"
if [[ ! -x "$ADB_BIN" ]]; then
  if command -v adb >/dev/null 2>&1; then
    ADB_BIN="$(command -v adb)"
  else
    echo "[smoke-android] adb not found. Set ADB_BIN or install Android platform-tools." >&2
    exit 1
  fi
fi

mkdir -p "$ROOT_DIR/docs/screenshots"

pick_emulator_id() {
  local emulator_bin="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}/emulator/emulator"
  if [[ ! -x "$emulator_bin" ]] && command -v emulator >/dev/null 2>&1; then
    emulator_bin="$(command -v emulator)"
  fi
  if [[ -x "$emulator_bin" ]]; then
    "$emulator_bin" -list-avds | awk 'NF {print; exit}'
  fi
}

ensure_device() {
  local emulator_id="${1:-}"
  "$ADB_BIN" start-server >/dev/null

  local current
  current="$("$ADB_BIN" devices | awk '/^emulator-[0-9]+[[:space:]]+device$/ {print $1; exit}')"
  if [[ -n "${current}" ]]; then
    echo "$current"
    return 0
  fi

  if [[ -z "$emulator_id" ]]; then
    emulator_id="$(pick_emulator_id)"
  fi
  if [[ -z "$emulator_id" ]]; then
    echo "[smoke-android] No Android emulator profile found via 'flutter emulators'." >&2
    exit 1
  fi

  echo "[smoke-android] launching emulator: $emulator_id" >&2
  local emulator_bin="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}/emulator/emulator"
  if [[ ! -x "$emulator_bin" ]] && command -v emulator >/dev/null 2>&1; then
    emulator_bin="$(command -v emulator)"
  fi
  if [[ ! -x "$emulator_bin" ]]; then
    echo "[smoke-android] emulator binary not found. Install Android SDK emulator or launch one manually." >&2
    exit 1
  fi
  nohup "$emulator_bin" -avd "$emulator_id" >/tmp/gtg_android_emulator.log 2>&1 &

  for _ in {1..120}; do
    current="$("$ADB_BIN" devices | awk '/^emulator-[0-9]+[[:space:]]+device$/ {print $1; exit}')"
    if [[ -n "$current" ]]; then
      local boot
      boot="$("$ADB_BIN" -s "$current" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')"
      if [[ "$boot" == "1" ]]; then
        echo "$current"
        return 0
      fi
    fi
    sleep 2
  done

  echo "[smoke-android] emulator boot timeout" >&2
  exit 1
}

DEVICE_ID="$(ensure_device "${1:-}" | tail -n 1)"
echo "[smoke-android] device: $DEVICE_ID"

"$ADB_BIN" -s "$DEVICE_ID" shell settings put global window_animation_scale 0 >/dev/null 2>&1 || true
"$ADB_BIN" -s "$DEVICE_ID" shell settings put global transition_animation_scale 0 >/dev/null 2>&1 || true
"$ADB_BIN" -s "$DEVICE_ID" shell settings put global animator_duration_scale 0 >/dev/null 2>&1 || true

echo "[smoke-android] flutter pub get"
flutter pub get >/dev/null

echo "[smoke-android] clear logcat"
"$ADB_BIN" -s "$DEVICE_ID" logcat -c || true

APP_ID="${APP_ID:-com.forevernewvie.projectgtg}"
echo "[smoke-android] build debug apk (UI_TESTING=true)"
flutter build apk \
  --debug \
  --dart-define=UI_TESTING=true \
  --dart-define=SMOKE_SCREENSHOTS=true >/dev/null

echo "[smoke-android] install apk"
"$ADB_BIN" -s "$DEVICE_ID" install -r "$ROOT_DIR/build/app/outputs/flutter-apk/app-debug.apk" >/dev/null

echo "[smoke-android] launch app via adb"
"$ADB_BIN" -s "$DEVICE_ID" shell am force-stop "$APP_ID" >/dev/null 2>&1 || true
"$ADB_BIN" -s "$DEVICE_ID" shell am start -n "$APP_ID/.MainActivity" >/dev/null

sleep 4

shot() {
  local name="$1"
  "$ADB_BIN" -s "$DEVICE_ID" exec-out screencap -p > "$ROOT_DIR/docs/screenshots/$name"
}

tap() {
  local x="$1"
  local y="$2"
  "$ADB_BIN" -s "$DEVICE_ID" shell input tap "$x" "$y"
}

# Home
shot "android_home.png"

# Calendar tab
tap 540 2140
sleep 1.5
shot "android_calendar.png"

# Settings tab
tap 900 2140
sleep 1.5
shot "android_settings.png"

# Reminders (first tile)
tap 240 260
sleep 1.5
shot "android_reminders.png"

# Back then All Logs (second tile)
"$ADB_BIN" -s "$DEVICE_ID" shell input keyevent 4
sleep 1.2
tap 240 390
sleep 1.5
shot "android_all_logs.png"

echo "[smoke-android] scan logcat for rendering/runtime errors"
LOG_DUMP="$("$ADB_BIN" -s "$DEVICE_ID" logcat -d || true)"
if printf '%s' "$LOG_DUMP" | rg -n "RenderFlex overflowed|EXCEPTION CAUGHT BY RENDERING LIBRARY|Fatal Exception" -S; then
  echo "[smoke-android] detected potential critical rendering/runtime errors" >&2
  exit 1
fi

echo "[smoke-android] screenshots saved:"
echo "  docs/screenshots/android_home.png"
echo "  docs/screenshots/android_calendar.png"
echo "  docs/screenshots/android_settings.png"
echo "  docs/screenshots/android_reminders.png"
echo "  docs/screenshots/android_all_logs.png"
