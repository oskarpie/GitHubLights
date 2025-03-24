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

# Check if iconutil is available
if command -v iconutil &> /dev/null; then
    # Create temporary iconset directory
    ICONSET="AppIcon.iconset"
    mkdir -p "$ICONSET"

    # Convert the SVG to PNG for various sizes
    # Requires rsvg-convert or similar tool
    if command -v rsvg-convert &> /dev/null; then
        for size in 16 32 64 128 256 512; do
            echo "Creating icon at ${size}x${size}..."
            rsvg-convert -w $size -h $size Sources/GitHubLights/AppIcon.svg -o "$ICONSET/icon_${size}x${size}.png"
            if [ $size -le 256 ]; then
                rsvg-convert -w $((size*2)) -h $((size*2)) Sources/GitHubLights/AppIcon.svg -o "$ICONSET/icon_${size}x${size}@2x.png"
            fi
        done

        # Create icns file
        echo "Creating .icns file..."
        iconutil -c icns "$ICONSET" -o "AppIcon.icns"
        mv "AppIcon.icns" "$APP_NAME/Contents/Resources/"
        rm -rf "$ICONSET"
    else
        echo "Warning: rsvg-convert not found. Skipping icon generation."
        # Copy a placeholder icon or skip
    fi
else
    echo "Warning: iconutil not found. Skipping icon generation."
fi

# Copy icon file directly
cp Resources/AppIcon.icns "$APP_NAME/Contents/Resources/"

# Create PkgInfo file
echo "APPLaplt" > "$APP_NAME/Contents/PkgInfo"

echo "App bundle created at $APP_NAME"
echo "You can move it to your Applications folder to install"
