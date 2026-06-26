#!/usr/bin/env bash
set -euo pipefail

APP_NAME="TraceAnime"
BUNDLE_ID="com.senya.TraceAnime"
MIN_SYSTEM_VERSION="14.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_BINARY="$APP_MACOS/$APP_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_ICON="$ROOT_DIR/Assets/TraceAnime.icns"
MENU_BAR_ICON="$ROOT_DIR/Assets/MenuBarIcon.png"

APP_VERSION="${APP_VERSION:-$(git -C "$ROOT_DIR" describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")}"
APP_VERSION="${APP_VERSION#v}"

rm -rf "$APP_BUNDLE" "$DIST_DIR/$APP_NAME.dmg" "$DIST_DIR/$APP_NAME"*.dmg
mkdir -p "$APP_MACOS" "$APP_RESOURCES"

swift "$ROOT_DIR/script/generate_icons.swift" "$ROOT_DIR"
iconutil -c icns "$ROOT_DIR/Assets/TraceAnime.iconset" -o "$APP_ICON"

swift build -c release
BUILD_BINARY="$(swift build -c release --show-bin-path)/$APP_NAME"

cp "$BUILD_BINARY" "$APP_BINARY"
cp "$APP_ICON" "$APP_RESOURCES/TraceAnime.icns"
cp "$MENU_BAR_ICON" "$APP_RESOURCES/MenuBarIcon.png"
chmod +x "$APP_BINARY"

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundleIconFile</key>
  <string>TraceAnime</string>
  <key>CFBundleShortVersionString</key>
  <string>$APP_VERSION</string>
  <key>CFBundleVersion</key>
  <string>$APP_VERSION</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

codesign --force --deep --options runtime --sign - "$APP_BUNDLE"
codesign --verify --deep --strict --verbose=2 "$APP_BUNDLE"

create-dmg \
  --overwrite \
  --no-version-in-filename \
  --no-code-sign \
  --dmg-title="$APP_NAME" \
  "$APP_BUNDLE" \
  "$DIST_DIR"

DMG_PATH="$DIST_DIR/$APP_NAME.dmg"
codesign --force --sign - "$DMG_PATH"
codesign --verify --verbose=2 "$DMG_PATH"

echo "$DMG_PATH"
