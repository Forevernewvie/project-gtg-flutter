#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SIM_NAME_DEFAULT="iPhone 17"
SIM_NAME="${1:-$SIM_NAME_DEFAULT}"

mkdir -p docs/screenshots

flutter pub get >/dev/null

echo "[smoke] build iOS (simulator)"
flutter build ios --simulator --debug \
  --dart-define=UI_TESTING=true \
  --dart-define=SMOKE_SCREENSHOTS=true >/dev/null

APP_PATH="$ROOT_DIR/build/ios/iphonesimulator/Runner.app"
if [[ ! -d "$APP_PATH" ]]; then
  echo "Runner.app not found at $APP_PATH" >&2
  exit 1
fi

BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP_PATH/Info.plist")

UDID=$(python3 - "$SIM_NAME" <<'PY'
import json
import subprocess
import sys

name = sys.argv[1]
raw = subprocess.check_output(
    ["xcrun", "simctl", "list", "devices", "available", "-j"],
    text=True,
)
payload = json.loads(raw)

devices = []
for _, items in payload.get("devices", {}).items():
    for d in items:
        if d.get("isAvailable"):
            devices.append(d)

# Prefer exact name match.
for d in devices:
    if d.get("name") == name:
        print(d.get("udid", ""))
        raise SystemExit(0)

# Fallback: first iPhone.
for d in devices:
    if "iPhone" in (d.get("name") or ""):
        print(d.get("udid", ""))
        raise SystemExit(0)

print("")
PY
)

if [[ -z "$UDID" ]]; then
  echo "No available iOS Simulator found." >&2
  exit 1
fi

echo "[smoke] boot simulator: $UDID ($SIM_NAME)"
xcrun simctl bootstatus "$UDID" -b >/dev/null 2>&1 || true

# Make screenshots deterministic.
xcrun simctl status_bar "$UDID" override \
  --time "9:41" \
  --batteryLevel 100 \
  --batteryState charged \
  --wifiBars 3 \
  --cellularBars 4 >/dev/null 2>&1 || true

xcrun simctl terminate "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl uninstall "$UDID" "$BUNDLE_ID" >/dev/null 2>&1 || true
xcrun simctl install "$UDID" "$APP_PATH" >/dev/null
xcrun simctl launch "$UDID" "$BUNDLE_ID" >/dev/null

sleep 0.3
xcrun simctl io "$UDID" screenshot "$ROOT_DIR/docs/screenshots/splash.png" >/dev/null
sleep 2.6
xcrun simctl io "$UDID" screenshot "$ROOT_DIR/docs/screenshots/home.png" >/dev/null

echo "[smoke] screenshots saved: docs/screenshots/splash.png, docs/screenshots/home.png"
