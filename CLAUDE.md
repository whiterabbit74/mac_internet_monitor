# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Internet Monitor is a lightweight macOS status bar application written in Swift that monitors internet connectivity in real-time. It displays connection status with color-coded icons (🟢/🟡/🔴) and provides detailed metrics through a status bar menu.

## Architecture

The application follows a clean architecture with these main components:

- **main.swift**: Application entry point that sets up NSApplication and AppDelegate
- **AppDelegate.swift**: Core application coordinator managing lifecycle, settings observers, and theme changes
- **StatusBarController.swift**: Manages the status bar icon, menu, and user interactions
- **NetworkMonitor.swift**: Handles connectivity checks using HTTP requests with ping fallback
- **PreferencesWindowController.swift**: Configuration window for user settings

### Key Design Patterns

- **Observer Pattern**: AppDelegate observes UserDefaults changes and system appearance changes to update UI dynamically
- **Delegation**: NetworkMonitor uses callbacks to notify StatusBarController of status changes
- **Fallback Strategy**: HTTP connectivity checks fallback to ping when web requests fail

## Development Commands

### Building and Running
```bash
# Build the application
make build

# Clean build artifacts
make clean

# Run the application directly
make run
swift run

# Quick build and launch app bundle
make quick

# Install to /Applications
make install
```

### Testing
```bash
# Run all tests
make test
swift test

# Run tests with code coverage (if using Xcode)
xcodebuild test -project InternetMonitor.xcodeproj -scheme InternetMonitor -enableCodeCoverage YES
```

### Development Setup
```bash
# Setup development environment and resolve dependencies
make setup
swift package resolve
```

## Project Structure

- **Sources/InternetMonitor/**: All Swift source files
- **Resources/**: Application resources (Info.plist, assets)
- **Tests/**: Unit tests
- **build/**: Build output directory with .app bundle
- **.build/**: Swift Package Manager build directory

## Configuration & Settings

The application uses UserDefaults for configuration with these key settings:
- `endpoint`: Target server for connectivity checks (default: "apple.com")
- `checkInterval`: Monitoring frequency in seconds (default: 5)
- `iconOpacity`: Status bar icon transparency (default: 0.5)
- `iconSize`: Status bar icon size in pixels (default: 18.0)
- `notificationsEnabled`: System notifications toggle
- `disconnectNotificationEnabled`: Show notifications on internet disconnect (default: enabled)
- `autoStartEnabled`: Launch at login
- `showInDock`: Show app icon in dock (default: false)

Settings changes are applied immediately without requiring app restart through observer pattern in AppDelegate.

## Network Monitoring Logic

NetworkMonitor implements a dual-strategy approach:
1. Primary: HTTPS HEAD requests to configured endpoint
2. Fallback: System ping to 8.8.8.8 if HTTP fails

Connection status determination:
- **Connected**: HTTP success with reasonable latency
- **Unstable**: High packet loss (≥30%) or high latency (≥500ms)
- **Disconnected**: Complete connectivity failure

## macOS Integration

- **Status Bar**: Uses NSStatusBar for system tray integration with custom vector icons
- **Theme Support**: Full light/dark mode with adaptive colors and gradients
- **Login Items**: Can be configured to launch at system startup
- **Notifications**: Modern UserNotifications framework with actionable alerts
- **Dock Integration**: Optional dock visibility (hidden by default with LSUIElement)
- **App Policy**: Dynamic switching between .accessory and .regular activation policies

## Swift Package Manager

The project uses Swift Package Manager with:
- Minimum target: macOS 13.0
- Architecture: Universal (Apple Silicon + Intel)
- No external dependencies (pure Foundation/AppKit)