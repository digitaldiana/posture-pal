#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APP="$ROOT/build/Posture Pal.app"

cd "$ROOT"
swift build -c release

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$ROOT/.build/release/PosturePal" "$APP/Contents/MacOS/PosturePal"
cp "$ROOT/Resources/Info.plist" "$APP/Contents/Info.plist"

codesign --force --deep --sign - "$APP"
printf 'Built %s\n' "$APP"
