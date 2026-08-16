#!/bin/bash
set -euo pipefail

APP="$HOME/Applications/Posture Pal.app"

if [ -d "$APP" ]; then
    osascript -e 'tell application "Posture Pal" to quit' 2>/dev/null || true
    rm -rf "$APP"
fi

printf 'Posture Pal was removed. Preferences remain in case you reinstall.\n'
