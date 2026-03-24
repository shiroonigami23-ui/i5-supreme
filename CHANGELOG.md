# Changelog
All notable changes to the **Web God Mode: i5 Supreme** extension will be documented in this file.

## [1.8] - 2026-03-25
### Added
- Ruby core library in `lib/i5_supreme`:
  - `ManifestManager` for manifest edits.
  - `RuleAuditor` for rules validation.
  - `ReleasePipeline` for zip/checksum/release-manifest generation.
  - `CLI` command interface in `bin/i5-supreme`.
- Ruby test suite (`test/*_test.rb`) and `Rakefile`.

### Changed
- Release workflow now uses the Ruby CLI entrypoint (`ruby bin/i5-supreme release:build ...`) for packaging.
- Extension version bumped to `1.8`.

## [1.7] - 2026-03-25
### Added
- Ruby release toolkit with checksum generation (`scripts/build_release.rb`, `scripts/release_checksums.rb`).
- EXE branding support with project icon (`icon/app.ico` used during OCRA build).
- Android companion app module and CI APK output (`i5-supreme-android.apk`).
- Release upload now ships ZIP + EXE + APK + checksums.

## [1.6] - 2026-03-25
### Added
- Ruby release pipeline using `scripts/release_builder.rb`.
- Windows `i5-supreme-packager.exe` artifact for one-click packaging.
- Automated GitHub release upload for both ZIP and EXE artifacts.

### Changed
- Improved manifest description text and added explicit homepage/about URL.

## [1.5] - 2026-01-02
### Added
- **Form Ghost:** Auto-fills junk data into sign-up walls.
- **Stealth Cloak:** Neutralizes anti-debugger loops.
- **Atomic Nuke:** Added `Alt + X` shortcut to vaporize elements.
- **Video Overdrive:** Added `S` key for 10x playback speed.
- **Copy Enforcer:** Global event suppression to enable text selection.

## [1.0] - 2026-01-01
### Added
- Initial release with basic paywall nuking and ad-blocking.
