#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p build
node --test tests/command.test.cjs
xcrun swiftc native/Particles.swift tests/ParticlesTests.swift -o build/particle-tests
build/particle-tests
helper=dist/tinycast-confetti/assets/Confetti.app
test -x "$helper/Contents/MacOS/confetti"
test "$("$helper/Contents/MacOS/confetti" --version)" = 'TinyCast Confetti 1.0.0'
for arch in arm64 x86_64; do
  xcrun lipo "$helper/Contents/MacOS/confetti" -verify_arch "$arch"
done
codesign --verify --strict "$helper"
if strings "$helper/Contents/MacOS/confetti" | /usr/bin/grep -Eq '/Users/|/home/|BEGIN .*PRIVATE KEY'; then
  printf 'Unexpected private build metadata in helper\n' >&2
  exit 1
fi
