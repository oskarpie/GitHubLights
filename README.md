# GitHub Lights

A lightweight macOS menu bar app that displays GitHub service status using traffic light indicators.

![lights2](https://github.com/user-attachments/assets/8f05508d-edbd-4816-90b3-80b14a2fdbcc)

## Features

- Shows GitHub service status as a 5x2 grid of colored traffic light indicators in the menu bar
- Green lights indicate operational services
- Orange/amber lights indicate degraded performance
- Red lights indicate outages
- Automatically refreshes every 5 minutes
- Click to view detailed status of each GitHub service
- Open GitHub Status page directly from the menu

## Installation

### Method 1: Build from Source

1. Clone this repository:

   ```shell
   git clone https://github.com/oskarpie/GitHubLights.git
   cd GitHubLights
   ```

2. Build and create the app bundle:

   ```shell
   ./build-app.sh
   ```

3. Move the app to your Applications folder:

   ```shell
   mv "GitHub Lights.app" /Applications/
   ```

4. Launch the app from Applications

### Method 2: Manual Installation

1. Build the Swift package:

   ```shell
   swift build -c release
   ```

2. Create the app bundle manually:

   ```shell
   mkdir -p "GitHub Lights.app/Contents/MacOS"
   mkdir -p "GitHub Lights.app/Contents/Resources"
   cp .build/release/GitHubLights "GitHub Lights.app/Contents/MacOS/"
   cp Resources/Info.plist "GitHub Lights.app/Contents/"
   echo "APPLaplt" > "GitHub Lights.app/Contents/PkgInfo"
   ```

3. Move to Applications:

   ```shell
   mv "GitHub Lights.app" /Applications/
   ```

## Development

- The app is built with Swift and uses the macOS AppKit framework
- It fetches data from the GitHub Status API at https://www.githubstatus.com/api/v2/summary.json
- To modify the app, edit the `main.swift` file in the `Sources/GitHubLights` directory

## Project Structure

```text
GitHubLights/
├── Package.swift                  # Swift package configuration
├── Sources/
│   └── GitHubLights/
│       └── main.swift             # Main application code
├── Resources/
│   ├── Info.plist                 # App bundle information
│   └── AppIcon.icns               # App icon 
├── build-app.sh                   # Build script
└── README.md                      # This file
```

## License

This project is available as open source under the terms of the MIT License.
