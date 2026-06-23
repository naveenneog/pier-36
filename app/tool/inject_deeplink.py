#!/usr/bin/env python3
"""Inject the Supabase OAuth deep-link intent-filter into the Android manifest.

Run from the ``app/`` directory after ``flutter create`` generates ``android/``.
Idempotent: safe to run multiple times. Used by ``.github/workflows/release.yml``.
"""

from __future__ import annotations

import pathlib
import sys

MANIFEST = pathlib.Path("android/app/src/main/AndroidManifest.xml")
SCHEME = "io.pier36.app"
HOST = "login-callback"

INTENT_FILTER = (
    "            <intent-filter>\n"
    '                <action android:name="android.intent.action.VIEW" />\n'
    '                <category android:name="android.intent.category.DEFAULT" />\n'
    '                <category android:name="android.intent.category.BROWSABLE" />\n'
    f'                <data android:scheme="{SCHEME}" android:host="{HOST}" />\n'
    "            </intent-filter>\n"
)


def inject(text: str) -> str | None:
    """Return patched manifest text, or None if already present."""
    if SCHEME in text:
        return None
    marker = "</activity>"
    idx = text.find(marker)
    if idx == -1:
        raise ValueError("<activity> block not found in manifest")
    return text[:idx] + INTENT_FILTER + text[idx:]


def main() -> int:
    if not MANIFEST.exists():
        print(f"ERROR: {MANIFEST} not found (run after `flutter create`)", file=sys.stderr)
        return 1
    patched = inject(MANIFEST.read_text(encoding="utf-8"))
    if patched is None:
        print("deep-link intent-filter already present; nothing to do")
        return 0
    MANIFEST.write_text(patched, encoding="utf-8")
    print(f"injected {SCHEME}://{HOST} intent-filter into AndroidManifest.xml")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
