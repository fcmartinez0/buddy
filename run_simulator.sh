#!/bin/bash
set -e

SCHEME="Buddy"
PROJECT="Buddy.xcodeproj"
BUNDLE_ID="com.buddy.app"

# Use the simulator passed as the first arg, otherwise auto-detect the first
# available iPhone simulator on this machine.
SIMULATOR="$1"
if [ -z "$SIMULATOR" ]; then
  SIMULATOR=$(xcrun simctl list devices available \
    | grep -Eo 'iPhone [0-9][^(]*' \
    | head -1 \
    | sed 's/[[:space:]]*$//')
fi

if [ -z "$SIMULATOR" ]; then
  echo "Error: no available iPhone simulator found."
  echo "Run 'xcrun simctl list devices available' to see what you have."
  exit 1
fi

echo "→ Building for simulator: $SIMULATOR"

build() {
  xcodebuild \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "platform=iOS Simulator,name=$SIMULATOR" \
    -configuration Debug \
    CODE_SIGNING_ALLOWED=NO \
    build "$@"
}

if command -v xcpretty >/dev/null 2>&1; then
  build | xcpretty
else
  build
fi

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
