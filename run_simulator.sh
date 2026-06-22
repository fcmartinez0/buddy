#!/bin/bash
set -e

SCHEME="Buddy"
PROJECT="Buddy.xcodeproj"
BUNDLE_ID="com.buddy.app"
SIMULATOR="${1:-iPhone 15}"   # pass a different name as first arg if needed

echo "→ Building for simulator: $SIMULATOR"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$SIMULATOR" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build | xcpretty 2>/dev/null || xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,name=$SIMULATOR" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build

echo "→ Finding built app"
APP=$(find ~/Library/Developer/Xcode/DerivedData/Buddy-*/Build/Products/Debug-iphonesimulator -name "Buddy.app" 2>/dev/null | head -1)
if [ -z "$APP" ]; then
  echo "Error: could not find Buddy.app in DerivedData"
  exit 1
fi
echo "  Found: $APP"

echo "→ Booting simulator"
xcrun simctl boot "$SIMULATOR" 2>/dev/null || true
open -a Simulator

echo "→ Installing"
xcrun simctl install booted "$APP"

echo "→ Launching"
xcrun simctl launch --console booted "$BUNDLE_ID"
