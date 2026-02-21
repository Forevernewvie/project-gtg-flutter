#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
HOOK_SRC="$ROOT_DIR/tool/git-hooks/pre-commit"
HOOK_DST="$ROOT_DIR/.git/hooks/pre-commit"

if [[ ! -f "$HOOK_SRC" ]]; then
  echo "Missing hook source: $HOOK_SRC"
  exit 1
fi

install -m 755 "$HOOK_SRC" "$HOOK_DST"
echo "Installed pre-commit hook -> $HOOK_DST"
