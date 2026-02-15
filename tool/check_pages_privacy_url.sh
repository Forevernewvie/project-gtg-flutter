#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

URLS=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  URLS+=("$line")
done < <("$ROOT_DIR/tool/print_pages_privacy_url.sh")

ok=0
for url in "${URLS[@]}"; do
  code="$(curl -s -o /dev/null -w "%{http_code}" -L -I "$url" || true)"
  echo "[pages] $url -> $code"
  if [[ "$code" == "200" || "$code" == "301" || "$code" == "302" ]]; then
    ok=1
  fi
done

if [[ "$ok" -eq 1 ]]; then
  exit 0
fi

echo "[pages] Not reachable yet. If you just enabled GitHub Pages, wait a few minutes and retry." >&2
exit 1

