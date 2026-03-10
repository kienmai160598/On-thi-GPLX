# GPLX2026 - Build & Install
# Usage:
#   make          - Build + install + show info
#   make build    - Build only (simulator, verifies compilation)
#   make install  - Install last build to iPhone
#   make info     - Show app & device info
#   make clean    - Clean build artifacts

SCHEME    = GPLX2026
PROJECT   = GPLX2026.xcodeproj
DEVICE_ID = 00008120-0016116A1103C01E
SIM_ID    = 720AD619-4FF4-43A9-B772-7EF4B9354A3F

DERIVED   = $(HOME)/Library/Developer/Xcode/DerivedData
APP_PATH  = $(shell find $(DERIVED)/GPLX2026-*/Build/Products/Debug-iphoneos -name "$(SCHEME).app" -maxdepth 1 2>/dev/null | head -1)
PBXPROJ   = $(PROJECT)/project.pbxproj
VERSION   = $(shell grep 'MARKETING_VERSION' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/;.*//' | tr -d ' ')
BUILD_NUM = $(shell grep 'CURRENT_PROJECT_VERSION' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/;.*//' | tr -d ' ')
BUNDLE_ID = $(shell grep 'PRODUCT_BUNDLE_IDENTIFIER' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/;.*//' | tr -d ' "')

.PHONY: all build install info clean

all: build install info

build:
	@echo "Building $(SCHEME) v$(VERSION) ($(BUILD_NUM))..."
	@xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,id=$(SIM_ID)' \
		build 2>&1 | tail -1

install:
	@if [ -z "$(APP_PATH)" ]; then \
		echo "No .app found in DerivedData. Build from Xcode (Cmd+R) first."; \
		exit 1; \
	fi
	@echo "Installing to iPhone..."
	@xcrun devicectl device install app \
		--device $(DEVICE_ID) "$(APP_PATH)" 2>&1 \
		| grep -E "App installed|bundleID|error" || true

info:
	@echo ""
	@echo "=== $(SCHEME) ==="
	@echo "  Version:   $(VERSION) ($(BUILD_NUM))"
	@echo "  Bundle ID: $(BUNDLE_ID)"
	@echo "  App size:  $$(du -sh "$(APP_PATH)" 2>/dev/null | cut -f1 || echo 'N/A')"
	@echo "  Built:     $$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$(APP_PATH)" 2>/dev/null || echo 'N/A')"
	@echo "  Device:    $(DEVICE_ID)"
	@echo ""

clean:
	@echo "Cleaning..."
	@xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean 2>&1 | tail -1
	@rm -rf build
	@echo "Done"
