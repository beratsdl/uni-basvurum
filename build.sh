#!/bin/bash
set -e

PROJECT="UniversityResearchManager.xcodeproj"
SCHEME="UniversityResearchManager"
CONFIG="Debug"
DEST="$HOME/Projects/UniBasvurum/App"
APP="UniversityResearchManager.app"

echo "Building $SCHEME ($CONFIG)..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  build \
  | grep -E "error:|warning:|BUILD" || true

BUILT_DIR=$(xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -showBuildSettings 2>/dev/null \
  | grep "^\s*BUILT_PRODUCTS_DIR " \
  | head -1 \
  | sed 's/.*= //')

mkdir -p "$DEST"
rm -rf "$DEST/$APP"
cp -R "$BUILT_DIR/$APP" "$DEST/"

echo "Kopyalandı → $DEST/$APP"
