#!/bin/bash

# Exit on error
set -e

echo "Building GitHub Lights macOS app..."

# Build the Swift app in release mode
swift build -c release

# Create app directory structure
APP_NAME="GitHub Lights.app"
rm -rf "$APP_NAME"
mkdir -p "$APP_NAME/Contents/MacOS"
mkdir -p "$APP_NAME/Contents/Resources"

# Copy executable
cp .build/release/GitHubLights "$APP_NAME/Contents/MacOS/"

# Copy Info.plist
cp Resources/Info.plist "$APP_NAME/Contents/"

# Copy icon file directly
echo "Copying icon file from Resources..."
cp Resources/AppIcon.icns "$APP_NAME/Contents/Resources/"

# Create PkgInfo file
echo "APPLaplt" > "$APP_NAME/Contents/PkgInfo"

echo "App bundle created at $APP_NAME"
echo "You can move it to your Applications folder to install"