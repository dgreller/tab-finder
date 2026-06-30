#!/bin/sh
# Tab Finder installer — copies the script to ~/.local/bin and prints next steps.
set -e

SRC="$(cd "$(dirname "$0")" && pwd)/tab-finder.applescript"
DEST_DIR="$HOME/.local/bin"
DEST="$DEST_DIR/tab-finder.applescript"

if [ ! -f "$SRC" ]; then
  echo "Error: tab-finder.applescript not found next to this installer." >&2
  exit 1
fi

mkdir -p "$DEST_DIR"
cp "$SRC" "$DEST"
echo "Installed: $DEST"
echo
echo "Next: create a hotkey in the Shortcuts app."
echo "  1. Shortcuts -> New Shortcut (Cmd-N)"
echo "  2. Add the 'Run Shell Script' action"
echo "  3. Paste this line into it:"
echo
echo "       osascript \"\$HOME/.local/bin/tab-finder.applescript\""
echo
echo "  4. Name it 'Tab Finder', then add a Keyboard Shortcut (e.g. Ctrl-Opt-Cmd-T)."
echo "  5. First run, approve the prompt to control Safari / Google Chrome."
