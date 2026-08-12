# Changelog

All notable changes to TextSnap will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-08-12

### Fixed
- Screen Recording permission was not detected correctly after granting access in System Settings. The app now uses `CGRequestScreenCaptureAccess()` which registers the app in TCC and triggers the system permission dialog on first use.
- Added "Quit & Relaunch" button to the permission alert so users can apply the granted permission without manually restarting the app.
- Permission error from ScreenCaptureKit during capture now shows the permission alert with a relaunch option instead of a generic error.

## [1.0.0] - 2026-08-12

### Added
- Menu bar app that lives in the system status bar
- Global shortcut `Command+Shift+2` to start text capture
- Per-display selection overlay with dimming effect
- Local OCR using Apple Vision framework (no internet required)
- Support for Japanese, English, and automatic language detection
- Plain text copy to clipboard after recognition
- Audio feedback on successful copy
- Recognition language selection (Auto / English / Japanese)
- Language correction toggle
- Sound toggle
- Launch at Login support via ServiceManagement
- Screen Recording permission guidance with direct link to System Settings
- Signed and notarized release for macOS 14.0+
