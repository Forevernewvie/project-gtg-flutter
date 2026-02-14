#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[gate] flutter pub get"
flutter pub get

echo "[gate] dart format (check)"
dart format --set-exit-if-changed .

echo "[gate] flutter analyze"
flutter analyze

echo "[gate] flutter test"
flutter test

echo "[gate] iOS smoke"
"$ROOT_DIR/tool/smoke_ios.sh"
