#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
helper=dist/tinycast-confetti/assets/Confetti.app
mkdir -p build "$helper/Contents/MacOS"
for arch in arm64 x86_64; do
  xcrun swiftc -O -whole-module-optimization -target "$arch-apple-macosx13.0" \
    native/Particles.swift native/main.swift -o "build/confetti-$arch"
done
xcrun lipo -create build/confetti-arm64 build/confetti-x86_64 -output "$helper/Contents/MacOS/confetti"
strip -x "$helper/Contents/MacOS/confetti"
cp native/Info.plist "$helper/Contents/Info.plist"
codesign --force --sign - --timestamp=none "$helper"
cp package.json confetti.js dist/tinycast-confetti/
cp assets/icon.svg dist/tinycast-confetti/assets/
cp LICENSE README.md SECURITY.md dist/tinycast-confetti/
COPYFILE_DISABLE=1 tar -czf dist/tinycast-confetti.tar.gz -C dist tinycast-confetti
printf 'Built dist/tinycast-confetti (arm64 + x86_64)\n'
