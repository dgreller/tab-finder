#!/bin/sh
# Optional: compile a double-clickable "Tab Finder.app" into ~/Applications.
# (Not required — the Shortcut hotkey runs the .applescript directly.)
set -e

SRC="$(cd "$(dirname "$0")" && pwd)/tab-finder.applescript"
APP="$HOME/Applications/Tab Finder.app"

mkdir -p "$HOME/Applications"
osacompile -o "$APP" "$SRC"
echo "Built: $APP"
echo "Note: it's unsigned, so on another Mac, Gatekeeper may require right-click -> Open the first time."
