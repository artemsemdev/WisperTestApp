#!/bin/bash
set -euo pipefail

echo "Building VoxFlow Desktop for macOS..."

dotnet publish src/VoxFlow.Desktop/VoxFlow.Desktop.csproj \
    -f net9.0-maccatalyst \
    -c Release \
    -r maccatalyst-arm64 \
    -p:CreatePackage=true

echo "Build artifacts in: src/VoxFlow.Desktop/bin/Release/net9.0-maccatalyst/maccatalyst-arm64/publish/"

# Generate SHA-256 checksum
APP_PATH=$(find src/VoxFlow.Desktop/bin/Release -name "*.pkg" -o -name "*.app" 2>/dev/null | head -1)
if [ -n "$APP_PATH" ]; then
    shasum -a 256 "$APP_PATH" > "${APP_PATH}.sha256"
    echo "Checksum: ${APP_PATH}.sha256"
fi
