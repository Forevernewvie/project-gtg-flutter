#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

STAGED_FILES="$(git diff --cached --name-only --diff-filter=ACMR)"
if [[ -z "$STAGED_FILES" ]]; then
  exit 0
fi

BLOCKED_PATH_REGEX='(^|/)\.env($|\..+)|(^|/)android/key\.properties$|(^|/).*\.(pem|p12|jks|keystore)$|(^|/)id_rsa($|\.pub$)'
TOKEN_REGEX='(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{60,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|-----BEGIN (RSA )?PRIVATE KEY-----|sk_live_[0-9A-Za-z]{20,}|xox[baprs]-[0-9A-Za-z-]{10,})'

BLOCKED_PATH_HITS="$(printf '%s\n' "$STAGED_FILES" | rg -n --pcre2 "$BLOCKED_PATH_REGEX" || true)"
if [[ -n "$BLOCKED_PATH_HITS" ]]; then
  echo "[secret-scan] Commit blocked: sensitive file path detected."
  echo "$BLOCKED_PATH_HITS"
  echo "Remove these files from staging and store secrets in local/CI secret stores."
  exit 1
fi

DIFF_HITS="$(git diff --cached --text -U0 | rg -n --pcre2 "$TOKEN_REGEX" || true)"
if [[ -n "$DIFF_HITS" ]]; then
  echo "[secret-scan] Commit blocked: possible secret detected in staged diff."
  echo "$DIFF_HITS"
  echo "Rotate exposed credentials immediately if this was a real secret."
  exit 1
fi

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "[secret-scan] gitleaks not found locally; regex guard ran. CI still enforces gitleaks."
fi

exit 0
