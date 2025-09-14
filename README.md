# Internet Monitor for macOS

A lightweight macOS application for real-time internet connection monitoring. Displays connection status in the macOS status bar.

## Features

- **Real-time monitoring** - Check internet connection every 5 seconds
- **Visual indicators** - Color-coded status bar icons (Green/Yellow/Red)
- **Detailed metrics** - Latency and packet loss in menu
- **Customizable settings** - Endpoint, check interval, notifications
- **System notifications** - Alerts on connection status changes
- **Minimalist UI** - Doesn't clutter your desktop
- **Clean Apple-style interface** - No emoji clutter, proper system fonts
- **Full English localization** - Complete English interface

## Connection States

| Status | Color | Description |
|--------|-------|-------------|
| Connected | Green | Stable connection |
| Unstable | Yellow | High ping or packet loss |
| Disconnected | Red | No internet connection |

## System Requirements

- **macOS**: 13.0 or newer
- **Architecture**: Apple Silicon (arm64) or Intel
- **Memory**: ~10MB RAM
- **CPU**: < 1% usage

## Installation

### From Releases
1. Download the latest release from [Releases](https://github.com/whiterabbit74/mac_internet_monitor/releases)
2. Extract `InternetMonitor-v1.0.5.zip`
3. Drag `InternetMonitor.app` to your `Applications` folder
4. Launch from Launchpad or Finder

### From Source
1. **Clone repository**
   ```bash
   git clone https://github.com/whiterabbit74/mac_internet_monitor.git
   cd mac_internet_bar
   ```

2. **Build with Swift Package Manager**
   ```bash
   make clean && make
   ```

3. **Run the application**
   ```bash
   open build/InternetMonitor.app
   ```

## Usage

### Main Interface

After launching, the app appears in the status bar (top menu bar):

- **Left click**: Open info menu
- **Right click**: Show context menu

### Application Menu

```
Internet Monitor v1.0.5
─────────────────────────
Status: Connected
Latency: 23ms
Packet Loss: 0%
─────────────────────────
Refresh Now
Settings...
─────────────────────────
Quit
```

### Settings

**All settings apply instantly without restart!**

1. Right-click the status bar icon
2. Select "Settings..."
3. Configure options:
   - **Endpoint**: Server to check (default: apple.com)
   - **Check interval**: Frequency in seconds (default: 5)
   - **Enable notifications**: System alerts on/off
   - **Show tooltips**: Display tooltip on hover
   - **Launch at login**: Auto-start with system
   - **Show in Dock**: App visibility in Dock
   - **Icon opacity**: Adjust transparency (10-100%)
   - **Icon size**: Customize size (12-24px)

## Configuration

### Available Endpoints
- **8.8.8.8 (Google DNS)**: Fast, reliable
- **apple.com (Apple)**: Good for macOS integration
- **1.1.1.1 (Cloudflare)**: Privacy-focused
- **yandex.ru (Yandex)**: Alternative option
- **Custom endpoint**: Your own server

### Advanced Configuration (Terminal)
```bash
# Change endpoint selection (0-4)
defaults write com.internetmonitor.app selectedEndpointIndex 2

# Set custom endpoint
defaults write com.internetmonitor.app customEndpoint "example.com"

# Change check interval (seconds)
defaults write com.internetmonitor.app checkInterval 10

# Disable notifications
defaults write com.internetmonitor.app notificationsEnabled false

# Enable auto-start
defaults write com.internetmonitor.app autoStartEnabled true

# Set icon opacity (0.1 - 1.0)
defaults write com.internetmonitor.app iconOpacity 0.5

# Set icon size (12.0 - 24.0 px)
defaults write com.internetmonitor.app iconSize 18.0
```

## Build System

The project uses Swift Package Manager with a Makefile for convenience:

```bash
# Clean and build
make clean && make

# Build only
make

# Install to Applications
make install

# Show help
make help
```

## Architecture

```
InternetMonitor/
├── Sources/InternetMonitor/
│   ├── AppDelegate.swift              # Main app delegate
│   ├── StatusBarController.swift      # Status bar management
│   ├── PreferencesWindowController.swift # Settings window
│   ├── NetworkMonitor.swift           # Network monitoring logic
│   ├── main.swift                     # Entry point
│   └── Info.plist                     # App configuration
├── Resources/                         # App resources
├── Tests/                             # Unit tests
├── Package.swift                      # Swift Package Manager config
├── Makefile                          # Build automation
└── README.md                         # This file
```

## Performance Metrics

- **Memory usage**: < 10MB
- **CPU usage**: < 1%
- **Response time**: < 100ms
- **Bundle size**: ~2MB

## Troubleshooting

### App won't start
1. Ensure macOS 13.0 or newer
2. Check permissions in System Settings → Security & Privacy
3. Try restarting the app

### Incorrect connection status
1. Check endpoint settings
2. Verify internet connection
3. Try different endpoint (1.1.1.1, 8.8.8.8)

### High resource usage
1. Increase check interval in settings
2. Restart the application
3. Check Activity Monitor

## Version History

### v1.0.5 (Latest)
- ✅ **Removed all emoji icons** - Clean, professional interface
- ✅ **Full English localization** - Complete translation
- ✅ **Apple-style interface** - System fonts and proper styling
- ✅ **Fixed launch issues** - Removed UserNotifications crashes
- ✅ **Clean codebase** - Removed unnecessary visual effects

### v1.0.4
- ✅ UI/UX improvements
- ✅ Dark/light theme support
- ✅ Memory leak fixes

### v1.0.3
- ✅ Basic internet monitoring
- ✅ Status bar integration
- ✅ Customizable settings
- ✅ System notifications
- ✅ Multiple endpoint support

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

MIT License - see [LICENSE](LICENSE) file

## Support

- 🐛 Issues: [GitHub Issues](https://github.com/whiterabbit74/mac_internet_monitor/issues)
- 📖 Documentation: [Wiki](https://github.com/whiterabbit74/mac_internet_monitor/wiki)

---

**Internet Monitor** - Your reliable internet connection guardian! 🌐