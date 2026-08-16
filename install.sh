#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
DESTINATION="$HOME/Applications/Posture Pal.app"

"$ROOT/build.sh"
mkdir -p "$HOME/Applications"
rm -rf "$DESTINATION"
cp -R "$ROOT/build/Posture Pal.app" "$DESTINATION"
open "$DESTINATION"

printf 'Installed and opened %s\n' "$DESTINATION"
