# GPLX2026 - Build & Install to iPhone
# Usage:
#   make install   - Build + install to connected iPhone (default)
#   make build     - Archive + export signed app
#   make clean     - Clean build artifacts
#   make device    - Show connected device info

SCHEME       = GPLX2026
PROJECT      = GPLX2026.xcodeproj
CONFIG       = Release
BUILD_DIR    = $(CURDIR)/build
ARCHIVE      = $(BUILD_DIR)/$(SCHEME).xcarchive
EXPORT_DIR   = $(BUILD_DIR)/export
EXPORT_PLIST = $(CURDIR)/ExportOptions.plist

DEVICE_ID := $(shell xcrun xctrace list devices 2>/dev/null | grep -i iphone | grep -v Simulator | head -1 | sed 's/.*(\(.*\))/\1/')

SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c
.PHONY: all build install clean device generate

all: install

generate:
	@if command -v xcodegen >/dev/null 2>&1; then \
		echo "🔧 Generating Xcode project..."; \
		xcodegen generate; \
	fi

build: generate
	@mkdir -p $(BUILD_DIR)
	@echo "📦 Archiving $(SCHEME)..."
	@xcodebuild archive \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIG) \
		-destination "generic/platform=iOS" \
		-archivePath $(ARCHIVE) \
		-allowProvisioningUpdates \
		CODE_SIGN_STYLE=Automatic \
		| xcpretty || xcodebuild archive \
		-project $(PROJECT) \
		-scheme $(SCHEME) \
		-configuration $(CONFIG) \
		-destination "generic/platform=iOS" \
		-archivePath $(ARCHIVE) \
		-allowProvisioningUpdates \
		CODE_SIGN_STYLE=Automatic 2>&1 | tail -5
	@echo "📤 Exporting signed app..."
	@xcodebuild -exportArchive \
		-archivePath $(ARCHIVE) \
		-exportOptionsPlist $(EXPORT_PLIST) \
		-exportPath $(EXPORT_DIR) \
		-allowProvisioningUpdates 2>&1 | tail -5
	@echo "✅ Build complete"

install: build
	@if [ -z "$(DEVICE_ID)" ]; then \
		echo "❌ No iPhone connected. Run 'make device' to check."; \
		exit 1; \
	fi
	@echo "📱 Installing to $(DEVICE_ID)..."
	@BUNDLE=$$(find $(EXPORT_DIR) -name "*.ipa" -o -name "*.app" | head -1); \
	if [ -z "$$BUNDLE" ]; then \
		echo "❌ No .app/.ipa found in $(EXPORT_DIR)"; \
		exit 1; \
	fi; \
	xcrun devicectl device install app --device $(DEVICE_ID) "$$BUNDLE"
	@echo "✅ Installed on iPhone!"

device:
	@echo "📱 Connected devices:"
	@xcrun xctrace list devices 2>/dev/null | grep -i iphone | grep -v Simulator || echo "   No iPhone found"

clean:
	@echo "🧹 Cleaning..."
	@rm -rf $(BUILD_DIR)
	@echo "✅ Clean"
