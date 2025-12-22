# RobusTest Web - Makefile
# Build and deployment automation

# Variables
APP_NAME := robustest-web
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_TIME := $(shell date -u '+%Y-%m-%d_%H:%M:%S')
LDFLAGS := -ldflags "-X main.Version=$(VERSION) -X main.BuildTime=$(BUILD_TIME) -s -w"

# Directories
SRC_DIR := ./cmd/server
PUBLIC_DIR := ./public
ASSETS_DIR := ./assets
DIST_DIR := ./dist
SCRIPTS_DIR := ./scripts

# Go settings
GOOS_LINUX := linux
GOARCH_AMD64 := amd64

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

.PHONY: all build dev clean test lint deps ui-build release help

## help: Show this help message
help:
	@echo "RobusTest Web - Build Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Development:"
	@echo "  dev          Start development server with live reload"
	@echo "  watch-css    Watch and rebuild CSS on changes"
	@echo "  templ        Generate templ files"
	@echo ""
	@echo "Build:"
	@echo "  build            Build for current platform"
	@echo "  build-linux      Build for Linux"
	@echo "  build-mac-intel  Build for macOS Intel"
	@echo "  build-mac-silicon Build for macOS Apple Silicon"
	@echo "  build-windows    Build for Windows"
	@echo "  build-all        Build for all platforms"
	@echo "  ui-build         Build and minify CSS/JS assets"
	@echo ""
	@echo "Release:"
	@echo "  release             Create Linux release (default)"
	@echo "  release-linux       Create Linux tarball"
	@echo "  release-mac-intel   Create macOS Intel tarball"
	@echo "  release-mac-silicon Create macOS Silicon tarball"
	@echo "  release-windows     Create Windows zip"
	@echo "  release-all         Create all platform releases"
	@echo ""
	@echo "Deployment:"
	@echo "  deploy-gce   Deploy to GCE instance"
	@echo ""
	@echo "Utilities:"
	@echo "  clean        Remove build artifacts"
	@echo "  deps         Install dependencies"
	@echo "  test         Run tests"
	@echo "  lint         Run linter"

## deps: Install all dependencies
deps:
	@echo "$(GREEN)Installing Go dependencies...$(NC)"
	go mod download
	go mod tidy
	@echo "$(GREEN)Installing Node dependencies...$(NC)"
	npm install
	@echo "$(GREEN)Installing templ...$(NC)"
	go install github.com/a-h/templ/cmd/templ@latest

## templ: Generate templ files
templ:
	@echo "$(GREEN)Generating templ files...$(NC)"
	templ generate

## ui-build: Build CSS assets
ui-build:
	@echo "$(GREEN)Building UI assets...$(NC)"
	@mkdir -p $(PUBLIC_DIR)/assets/css
	@echo "$(YELLOW)Building Tailwind CSS...$(NC)"
	npx @tailwindcss/cli -i ./src/css/input.css -o $(PUBLIC_DIR)/assets/css/app.css --minify
	@echo "$(VERSION)" > $(PUBLIC_DIR)/VERSION
	@echo "$(GREEN)UI build complete!$(NC)"

## watch-css: Watch CSS changes and rebuild
watch-css:
	npx @tailwindcss/cli -i ./src/css/input.css -o $(PUBLIC_DIR)/assets/css/app.css --watch

## build: Build for current platform
build: templ ui-build
	@echo "$(GREEN)Building $(APP_NAME)...$(NC)"
	go build $(LDFLAGS) -o $(APP_NAME) $(SRC_DIR)
	@echo "$(GREEN)Build complete: ./$(APP_NAME)$(NC)"

## build-linux: Build for Linux (production deployment)
build-linux: templ ui-build
	@echo "$(GREEN)Building $(APP_NAME) for Linux...$(NC)"
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o $(APP_NAME)-linux $(SRC_DIR)
	@echo "$(GREEN)Build complete: ./$(APP_NAME)-linux$(NC)"

## build-mac-intel: Build for macOS Intel
build-mac-intel: templ ui-build
	@echo "$(GREEN)Building $(APP_NAME) for macOS Intel...$(NC)"
	GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o $(APP_NAME)-mac-intel $(SRC_DIR)
	@echo "$(GREEN)Build complete: ./$(APP_NAME)-mac-intel$(NC)"

## build-mac-silicon: Build for macOS Apple Silicon
build-mac-silicon: templ ui-build
	@echo "$(GREEN)Building $(APP_NAME) for macOS Apple Silicon...$(NC)"
	GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o $(APP_NAME)-mac-silicon $(SRC_DIR)
	@echo "$(GREEN)Build complete: ./$(APP_NAME)-mac-silicon$(NC)"

## build-windows: Build for Windows
build-windows: templ ui-build
	@echo "$(GREEN)Building $(APP_NAME) for Windows...$(NC)"
	GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(APP_NAME).exe $(SRC_DIR)
	@echo "$(GREEN)Build complete: ./$(APP_NAME).exe$(NC)"

## build-all: Build for all platforms
build-all: templ ui-build
	@echo "$(GREEN)Building $(APP_NAME) for all platforms...$(NC)"
	@echo "$(YELLOW)Building Linux...$(NC)"
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o $(APP_NAME)-linux $(SRC_DIR)
	@echo "$(YELLOW)Building macOS Intel...$(NC)"
	GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o $(APP_NAME)-mac-intel $(SRC_DIR)
	@echo "$(YELLOW)Building macOS Apple Silicon...$(NC)"
	GOOS=darwin GOARCH=arm64 go build $(LDFLAGS) -o $(APP_NAME)-mac-silicon $(SRC_DIR)
	@echo "$(YELLOW)Building Windows...$(NC)"
	GOOS=windows GOARCH=amd64 go build $(LDFLAGS) -o $(APP_NAME).exe $(SRC_DIR)
	@echo "$(GREEN)All builds complete!$(NC)"
	@ls -lh $(APP_NAME)-* $(APP_NAME).exe 2>/dev/null || true

## dev: Start development server with live reload
dev:
	@echo "$(GREEN)Starting development server...$(NC)"
	@make templ
	@mkdir -p $(PUBLIC_DIR)/assets/css
	@npx @tailwindcss/cli -i ./src/css/input.css -o $(PUBLIC_DIR)/assets/css/app.css
	@echo "$(YELLOW)Starting server on http://localhost:3000$(NC)"
	@GIN_MODE=debug go run $(SRC_DIR)/main.go

## dev-watch: Start development with CSS watch (run in separate terminals)
dev-watch:
	@echo "$(GREEN)Starting development with file watching...$(NC)"
	@echo "$(YELLOW)Run 'make watch-css' in another terminal$(NC)"
	@make dev

## test: Run tests
test:
	@echo "$(GREEN)Running tests...$(NC)"
	go test -v ./...

## lint: Run linter
lint:
	@echo "$(GREEN)Running linter...$(NC)"
	golangci-lint run ./...

## clean: Remove build artifacts
clean:
	@echo "$(GREEN)Cleaning build artifacts...$(NC)"
	rm -f $(APP_NAME)
	rm -f $(APP_NAME)-linux
	rm -rf $(DIST_DIR)
	rm -rf $(PUBLIC_DIR)
	@echo "$(GREEN)Clean complete!$(NC)"

## release: Create Linux release tarball (default)
release: release-linux

## release-linux: Create Linux release tarball
release-linux: build-linux
	@echo "$(GREEN)Creating Linux release package...$(NC)"
	@mkdir -p $(DIST_DIR)
	@cp $(APP_NAME)-linux $(APP_NAME)
	tar -czvf $(DIST_DIR)/$(APP_NAME)-$(VERSION)-linux.tar.gz \
		$(APP_NAME) \
		$(PUBLIC_DIR) \
		.env.example \
		README.md
	@rm -f $(APP_NAME)
	@echo "$(GREEN)Release package created: $(DIST_DIR)/$(APP_NAME)-$(VERSION)-linux.tar.gz$(NC)"

## release-mac-intel: Create macOS Intel release tarball
release-mac-intel: build-mac-intel
	@echo "$(GREEN)Creating macOS Intel release package...$(NC)"
	@mkdir -p $(DIST_DIR)
	@cp $(APP_NAME)-mac-intel $(APP_NAME)
	tar -czvf $(DIST_DIR)/$(APP_NAME)-$(VERSION)-mac-intel.tar.gz \
		$(APP_NAME) \
		$(PUBLIC_DIR) \
		.env.example \
		README.md
	@rm -f $(APP_NAME)
	@echo "$(GREEN)Release package created: $(DIST_DIR)/$(APP_NAME)-$(VERSION)-mac-intel.tar.gz$(NC)"

## release-mac-silicon: Create macOS Apple Silicon release tarball
release-mac-silicon: build-mac-silicon
	@echo "$(GREEN)Creating macOS Apple Silicon release package...$(NC)"
	@mkdir -p $(DIST_DIR)
	@cp $(APP_NAME)-mac-silicon $(APP_NAME)
	tar -czvf $(DIST_DIR)/$(APP_NAME)-$(VERSION)-mac-silicon.tar.gz \
		$(APP_NAME) \
		$(PUBLIC_DIR) \
		.env.example \
		README.md
	@rm -f $(APP_NAME)
	@echo "$(GREEN)Release package created: $(DIST_DIR)/$(APP_NAME)-$(VERSION)-mac-silicon.tar.gz$(NC)"

## release-windows: Create Windows release zip
release-windows: build-windows
	@echo "$(GREEN)Creating Windows release package...$(NC)"
	@mkdir -p $(DIST_DIR)
	zip -r $(DIST_DIR)/$(APP_NAME)-$(VERSION)-windows.zip \
		$(APP_NAME).exe \
		$(PUBLIC_DIR) \
		.env.example \
		README.md
	@echo "$(GREEN)Release package created: $(DIST_DIR)/$(APP_NAME)-$(VERSION)-windows.zip$(NC)"

## release-all: Create release packages for all platforms
release-all: release-linux release-mac-intel release-mac-silicon release-windows
	@echo "$(GREEN)All release packages created:$(NC)"
	@ls -lh $(DIST_DIR)/

## deploy-gce: Deploy to GCE (requires gcloud configured)
deploy-gce: release
	@echo "$(GREEN)Deploying to GCE...$(NC)"
	@if [ -z "$(GCE_INSTANCE)" ]; then \
		echo "$(YELLOW)Error: GCE_INSTANCE not set$(NC)"; \
		echo "Usage: make deploy-gce GCE_INSTANCE=instance-name GCE_ZONE=us-west1-b GCE_PROJECT=project-id"; \
		exit 1; \
	fi
	@$(SCRIPTS_DIR)/deploy-gce.sh $(GCE_INSTANCE) $(GCE_ZONE) $(GCE_PROJECT)

## docker-build: Build Docker image
docker-build:
	@echo "$(GREEN)Building Docker image...$(NC)"
	docker build -t $(APP_NAME):$(VERSION) .
	docker tag $(APP_NAME):$(VERSION) $(APP_NAME):latest

## version: Show current version
version:
	@echo "Version: $(VERSION)"
	@echo "Build Time: $(BUILD_TIME)"

# Default target
all: build
