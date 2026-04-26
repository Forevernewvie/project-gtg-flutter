#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PUBSPEC = ROOT / "pubspec.yaml"
MANIFEST = ROOT / "docs" / "version.json"
REQUIRED_PLATFORMS = ("android", "ios")
REQUIRED_FIELDS = {
    "latestVersionCode": int,
    "latestVersionName": str,
    "forceUpdate": bool,
    "message": str,
    "storeUrl": str,
}


def fail(message: str) -> None:
    print(f"[hosted-update] ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read_pubspec_version() -> tuple[str, int]:
    match = re.search(r"^version:\s*([0-9]+(?:\.[0-9]+){2})\+([0-9]+)\s*$", PUBSPEC.read_text(), re.MULTILINE)
    if not match:
        fail("pubspec.yaml must contain version: <semver>+<buildNumber>")
    return match.group(1), int(match.group(2))


def validate_url(platform: str, url: str) -> None:
    if not url.startswith("https://"):
        fail(f"{platform}.storeUrl must be https://")
    if platform == "android" and "play.google.com/store/apps/details" not in url:
        fail("android.storeUrl must point to the Play Store listing")


def main() -> None:
    version_name, version_code = read_pubspec_version()
    try:
        manifest = json.loads(MANIFEST.read_text())
    except json.JSONDecodeError as error:
        fail(f"docs/version.json is invalid JSON: {error}")

    if not isinstance(manifest, dict):
        fail("docs/version.json root must be an object")

    for platform in REQUIRED_PLATFORMS:
        entry = manifest.get(platform)
        if not isinstance(entry, dict):
            fail(f"missing object for platform: {platform}")

        for field, expected_type in REQUIRED_FIELDS.items():
            value = entry.get(field)
            if not isinstance(value, expected_type):
                fail(f"{platform}.{field} must be {expected_type.__name__}")

        if entry["latestVersionName"] != version_name:
            fail(
                f"{platform}.latestVersionName={entry['latestVersionName']} does not match pubspec {version_name}"
            )
        if entry["latestVersionCode"] != version_code:
            fail(
                f"{platform}.latestVersionCode={entry['latestVersionCode']} does not match pubspec build {version_code}"
            )
        if not entry["message"].strip():
            fail(f"{platform}.message must not be blank")
        validate_url(platform, entry["storeUrl"])

    print(f"[hosted-update] OK: docs/version.json matches pubspec {version_name}+{version_code}")


if __name__ == "__main__":
    main()
