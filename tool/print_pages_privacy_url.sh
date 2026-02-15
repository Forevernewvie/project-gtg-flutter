#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

REMOTE="${1:-origin}"
REMOTE_URL="$(git remote get-url "$REMOTE" 2>/dev/null || true)"

if [[ -z "${REMOTE_URL:-}" ]]; then
  echo "[pages] Remote not found: $REMOTE" >&2
  exit 1
fi

PATH_PART=""
case "$REMOTE_URL" in
  https://github.com/*)
    PATH_PART="${REMOTE_URL#https://github.com/}"
    ;;
  git@github.com:*)
    PATH_PART="${REMOTE_URL#git@github.com:}"
    ;;
  ssh://git@github.com/*)
    PATH_PART="${REMOTE_URL#ssh://git@github.com/}"
    ;;
  *)
    echo "[pages] Unsupported remote URL (expected GitHub): $REMOTE_URL" >&2
    exit 1
    ;;
esac

PATH_PART="${PATH_PART%.git}"
USER="${PATH_PART%%/*}"
REPO="${PATH_PART#*/}"
REPO="${REPO%%/*}"

if [[ -z "${USER:-}" || -z "${REPO:-}" ]]; then
  echo "[pages] Failed to parse user/repo from: $REMOTE_URL" >&2
  exit 1
fi

BASE="https://${USER}.github.io/${REPO}"

echo "${BASE}/privacy_policy.html"
echo "${BASE}/privacy_policy"

