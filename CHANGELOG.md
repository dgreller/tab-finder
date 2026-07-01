# Changelog

All notable changes to Tab Finder are documented here.
Format loosely follows [Keep a Changelog](https://keepachangelog.com/); versioning is [SemVer](https://semver.org/).

## [1.0.1] - 2026-06-30

### Fixed
- **Jumping to a tab in a minimized window now restores the correct window.**
  Windows were referenced by their z-order position, which shifts between when
  the switcher builds its list and when you pick — so it could act on the wrong
  window and leave the intended (minimized) one in the Dock. Windows are now
  referenced by their **stable window `id`**, and the target window is
  explicitly un-minimized (Chrome `minimized` / Safari `miniaturized`) before
  being raised and activated. Uses only Automation permission (no Accessibility).

## [1.0.0] - 2026-06-30

### Added
- Initial release: floating search over all open Safari + Chrome tabs, live
  substring filtering (title/URL/browser), keyboard-driven navigation, jump to
  tab on Return/double-click. 100% local, no background process, no network.
