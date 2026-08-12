#!/usr/bin/env bash
# distribute.sh — Sign, notarize, staple, and package TextSnap for release.
#
# Usage:
#   ./scripts/distribute.sh /path/to/exported/TextSnap.app [version]
#
# Prerequisites:
#   1. Archive and export TextSnap.app from Xcode using Developer ID Application.
#   2. Store notarytool credentials in your keychain:
#      xcrun notarytool store-credentials "TextSnap-Notary" \
#        --apple-id "YOUR_APPLE_ID" \
#        --team-id "96SLZH78FC" \
#        --password "APP_SPECIFIC_PASSWORD"
#      (App-specific password: https://appleid.apple.com → Sign-In & Security → App-Specific Passwords)

set -euo pipefail

APP_PATH="${1:-}"
VERSION="${2:-$(date +%Y%m%d)}"
KEYCHAIN_PROFILE="TextSnap-Notary"
BUNDLE_ID="com.kohei.TextSnap"

if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  echo "Usage: $0 /path/to/TextSnap.app [version]"
  exit 1
fi

APP_NAME=$(basename "$APP_PATH" .app)
WORK_DIR=$(mktemp -d)
ZIP_FOR_NOTARIZE="$WORK_DIR/${APP_NAME}-notarize.zip"
DMG_STAGING="$WORK_DIR/dmg"
DMG_PATH="${APP_NAME}-${VERSION}.dmg"
DMG_ZIP="${APP_NAME}-${VERSION}.zip"

echo "=== TextSnap Distribution Script ==="
echo "App:     $APP_PATH"
echo "Version: $VERSION"
echo ""

# --- Step 1: Verify code signature ---
echo "[1/7] Verifying code signature..."
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
echo "      Signature OK"

# --- Step 2: Create zip for notarization ---
echo "[2/7] Creating zip for notarization..."
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_FOR_NOTARIZE"

# --- Step 3: Submit for notarization ---
echo "[3/7] Submitting to Apple Notarization Service (this may take a few minutes)..."
xcrun notarytool submit "$ZIP_FOR_NOTARIZE" \
  --keychain-profile "$KEYCHAIN_PROFILE" \
  --wait

# --- Step 4: Staple the app ---
echo "[4/7] Stapling notarization ticket to app..."
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"
echo "      Staple OK"

# --- Step 5: Create DMG ---
echo "[5/7] Creating DMG..."
mkdir -p "$DMG_STAGING"
cp -r "$APP_PATH" "$DMG_STAGING/"
ln -s /Applications "$DMG_STAGING/Applications"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_STAGING" \
  -ov \
  -format UDZO \
  -fs HFS+ \
  "$WORK_DIR/tmp_$APP_NAME.dmg"

cp "$WORK_DIR/tmp_$APP_NAME.dmg" "$DMG_PATH"
echo "      DMG created: $DMG_PATH"

# --- Step 6: Notarize and staple DMG ---
echo "[6/7] Notarizing DMG..."
DMG_ZIP_FOR_NOTARIZE="$WORK_DIR/${APP_NAME}-dmg-notarize.zip"
ditto -c -k --sequesterRsrc --keepParent "$DMG_PATH" "$DMG_ZIP_FOR_NOTARIZE"

xcrun notarytool submit "$DMG_ZIP_FOR_NOTARIZE" \
  --keychain-profile "$KEYCHAIN_PROFILE" \
  --wait

xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"
echo "      DMG staple OK"

# --- Step 7: Create distribution zip and final verification ---
echo "[7/7] Final verification..."
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
spctl --assess --type execute --verbose=4 "$APP_PATH"

ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$DMG_ZIP"

echo ""
echo "=== Done ==="
echo "DMG:  $DMG_PATH"
echo "ZIP:  $DMG_ZIP"
echo ""
echo "Upload both to the GitHub Release. Attach TextSnap-${VERSION}.dmg as the primary download."

# Cleanup
rm -rf "$WORK_DIR"
