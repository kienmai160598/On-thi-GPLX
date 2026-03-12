# GPLX2026 - Build & Install
# Usage:
#   make              - Build + install to both devices + show info
#   make build        - Build for device (verifies compilation)
#   make install      - Install to both iPhone and iPad
#   make iphone       - Install to iPhone only
#   make ipad         - Install to iPad only
#   make info         - Show app & device info
#   make clean        - Clean build artifacts

SCHEME    = GPLX2026
PROJECT   = GPLX2026.xcodeproj
IPHONE_ID = 6308D40C-1BEC-5B2A-88EC-687026979B79
IPAD_ID   = 0F57637E-4EFA-516B-850D-063A6D0D6FFB
SIM_ID    = 720AD619-4FF4-43A9-B772-7EF4B9354A3F

DERIVED   = $(HOME)/Library/Developer/Xcode/DerivedData
APP_PATH  = $(shell find $(DERIVED)/GPLX2026-*/Build/Products/Debug-iphoneos -name "$(SCHEME).app" -maxdepth 1 2>/dev/null | head -1)
PBXPROJ   = $(PROJECT)/project.pbxproj
VERSION   = $(shell grep 'MARKETING_VERSION' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/;.*//' | tr -d ' ')
BUILD_NUM = $(shell grep 'CURRENT_PROJECT_VERSION' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/;.*//' | tr -d ' ')
BUNDLE_ID = $(shell grep 'PRODUCT_BUNDLE_IDENTIFIER' $(PBXPROJ) | head -1 | sed 's/.*= *//;s/;.*//' | tr -d ' "')

.PHONY: all build install iphone ipad info clean

all: build install info

build:
	@echo "Building $(SCHEME) v$(VERSION) ($(BUILD_NUM))..."
	@xcodebuild -project $(PROJECT) -scheme $(SCHEME) \
		-destination 'generic/platform=iOS' \
		build 2>&1 | tail -1

install: iphone ipad

iphone:
	@if [ -z "$(APP_PATH)" ]; then \
		echo "No .app found in DerivedData. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Installing to iPhone..."
	@xcrun devicectl device install app \
		--device $(IPHONE_ID) "$(APP_PATH)" 2>&1 \
		| grep -E "App installed|bundleID|error" || true

ipad:
	@if [ -z "$(APP_PATH)" ]; then \
		echo "No .app found in DerivedData. Run 'make build' first."; \
		exit 1; \
	fi
	@echo "Installing to iPad..."
	@xcrun devicectl device install app \
		--device $(IPAD_ID) "$(APP_PATH)" 2>&1 \
		| grep -E "App installed|bundleID|error" || true

info:
	@echo ""
	@echo "=== $(SCHEME) ==="
	@echo "  Version:   $(VERSION) ($(BUILD_NUM))"
	@echo "  Bundle ID: $(BUNDLE_ID)"
	@echo "  App size:  $$(du -sh "$(APP_PATH)" 2>/dev/null | cut -f1 || echo 'N/A')"
	@echo "  Built:     $$(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$(APP_PATH)" 2>/dev/null || echo 'N/A')"
	@echo "  iPhone:    $(IPHONE_ID)"
	@echo "  iPad:      $(IPAD_ID)"
	@echo ""

clean:
	@echo "Cleaning..."
	@xcodebuild -project $(PROJECT) -scheme $(SCHEME) clean 2>&1 | tail -1
	@rm -rf build
	@echo "Done"
