# Tab Finder

A tiny, fast browser-tab switcher for macOS. Hit a hotkey, a search box pops up,
type any text to filter your open tabs **live** (across **Safari and Chrome** at
once), press Return to jump straight to the tab.

No app to install, no menu-bar process, nothing running in the background. It's a
single native AppleScript that only does anything when you press your hotkey.

## Features

- **Searches Safari + Chrome together** — one list, every open tab in both.
- **Live substring filter** — type `yahoo` and it matches `... - Yahoo Mail`
  anywhere in the title *or* URL (not just the start).
- Filter by browser too — type `chrome` or `safari`.
- **Keyboard-driven** — type to filter, `↑`/`↓` to move, `Return` to jump,
  `Esc` to cancel. Double-click a row also works.
- **100% local & private** — it reads your open tabs on your machine and makes
  **zero network calls**. Nothing leaves your computer.
- Skips a browser that isn't running (never launches one just to look).

## Requirements

- macOS (uses the built-in Shortcuts app for the hotkey; no third-party tools).
- Safari and/or Google Chrome.

## Install

1. Download/clone this folder, then run the installer:

   ```sh
   ./install.sh
   ```

   This copies `tab-finder.applescript` to `~/.local/bin/` and prints the exact
   line you'll paste into a Shortcut.

2. Bind a hotkey (one-time, ~6 clicks):
   1. Open the **Shortcuts** app → **⌘N** for a new shortcut.
   2. Search the Actions list for **Run Shell Script** and add it.
   3. Paste this into the script box:
      ```sh
      osascript "$HOME/.local/bin/tab-finder.applescript"
      ```
   4. Rename the shortcut **Tab Finder**.
   5. Open the shortcut's **details panel** (sliders icon, top-right) →
      **Add Keyboard Shortcut** → press a combo that no app uses. Good choice:
      **⌃⌥⌘T** (Control-Option-Command-T). Avoid plain `⌘`-letter combos — they
      collide with browser menus (e.g. `⌘T` = New Tab).

3. First run, macOS will ask to let it **control Safari / Google Chrome** —
   click **OK**. (This is the standard Automation permission; it's how the script
   reads your tabs and switches to one.)

That's it. Press your hotkey from anywhere.

## Usage

| Key | Action |
|-----|--------|
| *type* | filter tabs live (matches title + URL + browser name) |
| `↑` / `↓` | move the highlight |
| `Return` | jump to the highlighted tab |
| `Esc` | cancel |
| double-click | jump to that tab |

## Extending it

The browsers are handled in two places in `tab-finder.applescript`:
`gatherTabs()` (which reads tabs) and `jumpTo()` (which switches to one). Any
AppleScript-scriptable browser (Brave, Edge, Arc, Vivaldi — most Chromium
browsers use the same `title` / `URL` / `active tab index` terms as Chrome) can
be added by copying the Chrome block and changing the application name.

## Uninstall

```sh
rm ~/.local/bin/tab-finder.applescript
```

Then delete the **Tab Finder** shortcut in the Shortcuts app.

## License

MIT — see [LICENSE](LICENSE).
