# TextSnap

**[Distribution site](https://isitest1.github.io/TextSnap/) · [Download DMG](https://github.com/isitest1/TextSnap/releases/latest/download/TextSnap.dmg) · [Releases](https://github.com/isitest1/TextSnap/releases)**

A lightweight macOS menu bar app that captures text from any area of your screen using local OCR — no internet required.

Inspired by Windows PowerToys Text Extractor.

## Features

- **Global shortcut** — Press `⌘⇧2` from any app to start capturing
- **Select any region** — Draw a rectangle over any text on screen
- **Instant OCR** — Text is recognized locally using Apple Vision
- **Clipboard ready** — Result is copied as plain text automatically
- **Multi-display support** — Works across all connected displays and Retina screens
- **Japanese + English** — Recognizes both languages, individually or mixed
- **Menu bar only** — No Dock icon, no windows, no clutter

## Privacy

TextSnap processes screenshots and recognized text locally on your Mac. It does not upload, store, or transmit captured images or OCR results.

No account. No analytics. No network requests.

## Requirements

- macOS 14.0 (Sonoma) or later
- Screen Recording permission (prompted on first use)

## Installation

1. Download [`TextSnap.dmg`](https://github.com/isitest1/TextSnap/releases/latest/download/TextSnap.dmg) from the latest release
2. Open the DMG and drag **TextSnap** to your Applications folder
3. Launch TextSnap from Applications
4. Grant **Screen Recording** permission when prompted

> TextSnap is signed with a Developer ID certificate and notarized by Apple. macOS Gatekeeper will not block the app.

## Screen Recording Permission

TextSnap needs Screen Recording access to capture the area you select and recognize its text locally on your Mac.

If the permission prompt does not appear automatically:

1. Open **System Settings → Privacy & Security → Screen Recording**
2. Enable the toggle for **TextSnap**
3. Restart TextSnap

## Usage

| Step | Action |
|------|--------|
| 1 | Press `⌘⇧2` (or click **Capture Text** in the menu bar) |
| 2 | Drag to select the region containing text |
| 3 | Release — text is recognized and copied to clipboard |
| 4 | Paste with `⌘V` anywhere |

**Cancel:** Press `Escape` or right-click during selection.

## Recognition Languages

Open the TextSnap menu bar icon and choose **Recognition Language**:

| Option | Description |
|--------|-------------|
| Auto (Japanese + English) | Recognizes both languages in the same image (default) |
| English | Optimized for English-only text |
| Japanese | Optimized for Japanese-only text |

**Language Correction** applies linguistic post-processing. It is off by default because it can alter technical text such as code, URLs, and product identifiers.

## Build from Source

**Requirements:** Xcode 26 or later, macOS 14 SDK

```bash
git clone https://github.com/isitest1/TextSnap.git
cd TextSnap
open TextSnap.xcodeproj
```

Select the **TextSnap** scheme and press `⌘R` to build and run.

No external dependencies or Swift packages are required.

## Signed and Notarized Releases

Official releases are:

- Signed with a **Developer ID Application** certificate
- **Notarized** by Apple and stapled to the binary
- Verified with `codesign --verify --deep --strict` and `spctl --assess`

To verify a downloaded release yourself:

```bash
codesign --verify --deep --strict --verbose=2 TextSnap.app
spctl --assess --type execute --verbose=4 TextSnap.app
```

## Troubleshooting

**Menu bar icon is not visible**
The icon may be hidden behind other menu bar items. Hold `⌘` and drag menu bar icons to rearrange them, or check the overflow area.

**Shortcut does not work**
Another app may have registered `⌘⇧2`. Check System Settings → Keyboard → Keyboard Shortcuts for conflicts.

**OCR result is empty or inaccurate**
- Ensure the selected region contains clear, readable text
- Try a different Recognition Language setting
- Very small text (below ~10pt) may not be recognized reliably

**"Screen Recording" permission prompt does not appear**
Go to System Settings → Privacy & Security → Screen Recording, add TextSnap manually, then restart it.

## License

[MIT License](LICENSE) — Copyright © 2026 Margherita Works by Kohei Ishikawa
