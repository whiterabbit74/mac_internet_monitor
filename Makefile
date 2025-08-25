# Internet Monitor Build Script

.PHONY: all clean build test install run setup help info

# Variables
PROJECT_NAME = InternetMonitor
BUILD_DIR = .build
APP_NAME = $(PROJECT_NAME).app
BUNDLE_ID = com.internetmonitor.app
SWIFT_BUILD = swift build
SWIFT_RUN = swift run

# Default target
all: build

# Clean build directory
clean:
	@echo "🧹 Cleaning build directory..."
	@rm -rf $(BUILD_DIR)
	@rm -rf build
	@rm -rf $(APP_NAME)
	@echo "✅ Clean complete"

# Build the application
build:
	@echo "🔨 Building $(PROJECT_NAME) with Swift Package Manager..."
	@$(SWIFT_BUILD) --configuration release
	@echo "✅ Swift build complete"

	@echo "📦 Creating macOS app bundle in build folder..."
	@mkdir -p build/$(APP_NAME)/Contents/MacOS
	@mkdir -p build/$(APP_NAME)/Contents/Resources

	@echo "📋 Copying Info.plist..."
	@cp Sources/InternetMonitor/Info.plist build/$(APP_NAME)/Contents/
	@sed -i '' '/NSMainNibFile/d' build/$(APP_NAME)/Contents/Info.plist

	@echo "🔧 Copying executable..."
	@cp $(BUILD_DIR)/release/InternetMonitor build/$(APP_NAME)/Contents/MacOS/
	@chmod +x build/$(APP_NAME)/Contents/MacOS/InternetMonitor

	@echo "🎨 Copying resources..."
	@cp -r Sources/InternetMonitor build/$(APP_NAME)/Contents/Resources/ 2>/dev/null || true
	@cp README.md build/$(APP_NAME)/Contents/Resources/ 2>/dev/null || true

	@echo "✅ App bundle created: build/$(APP_NAME)"

# Run the application
run:
	@echo "🚀 Running $(PROJECT_NAME)..."
	@$(SWIFT_RUN)

# Run tests
test:
	@echo "🧪 Running tests..."
	@swift test
	@echo "✅ Tests complete"

# Install to Applications folder
install: build
	@echo "📥 Installing to /Applications..."
	@cp -r build/$(APP_NAME) /Applications/
	@echo "✅ Installed to /Applications/$(APP_NAME)"

# Development setup
setup:
	@echo "⚙️  Setting up development environment..."
	@echo "📦 Resolving Swift Package dependencies..."
	@swift package resolve
	@echo "✅ Development environment ready"

# Show help
help:
	@echo "Internet Monitor Build System"
	@echo ""
	@echo "Available targets:"
	@echo "  all      - Build the application (default)"
	@echo "  clean    - Clean build directory"
	@echo "  build    - Build the application"
	@echo "  run      - Run the application directly"
	@echo "  test     - Run tests"
	@echo "  install  - Install to /Applications"
	@echo "  setup    - Setup development environment"
	@echo "  help     - Show this help message"
	@echo ""
	@echo "Usage: make [target]"

# Show project info
info:
	@echo "📊 Project Information"
	@echo "Name: $(PROJECT_NAME)"
	@echo "Bundle ID: $(BUNDLE_ID)"
	@echo "Build Dir: $(BUILD_DIR)"
	@echo "App Bundle: $(APP_NAME)"
	@echo "Swift Package: Yes"

# Quick build and run
quick: clean build
	@echo "🎯 Quick build complete, running app..."
	@open build/$(APP_NAME)
