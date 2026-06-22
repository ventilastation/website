.SHELLFLAGS := -eu -o pipefail -c
SHELL := /bin/bash
.PHONY: install-deps roms roms-js bundle publish start start-webserver stop-webserver local-pages-build deploy-local

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
VSDK_DIR ?= $(ROOT_DIR)/vsdk
OUT_DIR ?= $(ROOT_DIR)/emulator
NODE ?= node
HOST ?= 127.0.0.1
PORT ?= 8000
TMP_DIR ?= $(ROOT_DIR)/.tmp
SERVER_PID_FILE ?= $(TMP_DIR)/emulator-http-server.pid
SERVER_LOG ?= $(TMP_DIR)/emulator-http-server.log
RUBY_BIN_DIR ?= /usr/local/opt/ruby@3.3/bin
BUNDLER_VERSION ?= 2.5.11
TMP_HOME ?= /private/tmp/codex-bundler-home
OUTPUT_DIR ?= $(ROOT_DIR)/_site_local_pages_test
PYTHON := $(if $(wildcard $(VSDK_DIR)/.venv/bin/python),$(VSDK_DIR)/.venv/bin/python,python3)
ROMS_STAMP := $(TMP_DIR)/roms.stamp
BUNDLE_STAMP := $(TMP_DIR)/bundle.stamp
PUBLISH_STAMP := $(OUT_DIR)/.publish-stamp

install-deps:
	@cd "$(VSDK_DIR)" && python3 -m venv .venv
	@"$(VSDK_DIR)/.venv/bin/python" -m pip install -r "$(VSDK_DIR)/requirements.txt"
	@echo "Installed VSDK Python dependencies into $(VSDK_DIR)/.venv"

roms:
	@mkdir -p "$(TMP_DIR)"
	@$(PYTHON) -c 'import numpy, yaml; from PIL import Image' || { \
		echo "Missing Python dependencies for ROM generation." >&2; \
		echo "Expected virtualenv per VSDK docs: $(VSDK_DIR)/.venv" >&2; \
		echo "Install them with: make install-deps" >&2; \
		exit 1; \
	}
	@if [ ! -f "$(ROMS_STAMP)" ] || [ "$(VSDK_DIR)/tools/generate_roms.py" -nt "$(ROMS_STAMP)" ] || [ "$(VSDK_DIR)/requirements.txt" -nt "$(ROMS_STAMP)" ] || find "$(VSDK_DIR)/games" "$(VSDK_DIR)/system" -type f \( -name '*.png' -o -name '__images__.yaml' \) -newer "$(ROMS_STAMP)" | grep -q .; then \
		cd "$(VSDK_DIR)/tools" && $(PYTHON) generate_roms.py; \
		touch "$(ROMS_STAMP)"; \
	else \
		echo "ROMs are up to date"; \
	fi

roms-js:
	@cd "$(VSDK_DIR)" && $(NODE) tools/generate_roms_js.cjs

bundle: roms
	@mkdir -p "$(TMP_DIR)"
	@if [ ! -f "$(BUNDLE_STAMP)" ] || [ "$(VSDK_DIR)/tools/generate_web_runtime_bundle.py" -nt "$(BUNDLE_STAMP)" ] || find -L "$(VSDK_DIR)/web" "$(VSDK_DIR)/apps" "$(VSDK_DIR)/games" "$(VSDK_DIR)/system" -type f -newer "$(BUNDLE_STAMP)" | grep -q .; then \
		cd "$(VSDK_DIR)" && $(PYTHON) tools/generate_web_runtime_bundle.py; \
		touch "$(BUNDLE_STAMP)"; \
	else \
		echo "Runtime bundle is up to date"; \
	fi

publish: bundle
	@mkdir -p "$(OUT_DIR)"
	@if [ ! -f "$(PUBLISH_STAMP)" ] || [ "$(ROOT_DIR)/tools/update-emulator-from-vsdk.sh" -nt "$(PUBLISH_STAMP)" ] || find -L "$(VSDK_DIR)/web" "$(VSDK_DIR)/apps" -type f -newer "$(PUBLISH_STAMP)" | grep -q .; then \
		"$(ROOT_DIR)/tools/update-emulator-from-vsdk.sh" "$(VSDK_DIR)" "$(OUT_DIR)"; \
		touch "$(PUBLISH_STAMP)"; \
	else \
		echo "Published emulator tree is up to date"; \
	fi

stop-webserver:
	@mkdir -p "$(TMP_DIR)"
	@existing_pid="$$(cat "$(SERVER_PID_FILE)" 2>/dev/null || true)"; \
	if [ -n "$$existing_pid" ] && kill -0 "$$existing_pid" 2>/dev/null; then \
		kill "$$existing_pid" || true; \
	fi
	@port_pid="$$(lsof -tiTCP:"$(PORT)" -sTCP:LISTEN 2>/dev/null || true)"; \
	if [ -n "$$port_pid" ]; then \
		kill $$port_pid || true; \
	fi
	@rm -f "$(SERVER_PID_FILE)"

start: publish stop-webserver
	@mkdir -p "$(TMP_DIR)"
	@cd "$(OUT_DIR)" && nohup $(PYTHON) -m http.server "$(PORT)" --bind "$(HOST)" >"$(SERVER_LOG)" 2>&1 & echo $$! >"$(SERVER_PID_FILE)"
	@sleep 1
	@echo "Serving $(OUT_DIR) at http://$(HOST):$(PORT)/"
	@echo "PID: $$(cat "$(SERVER_PID_FILE)")"
	@echo "Log: $(SERVER_LOG)"

start-webserver: start

deploy-local: start

local-pages-build: publish
	@if [ ! -x "$(RUBY_BIN_DIR)/ruby" ] || [ ! -x "$(RUBY_BIN_DIR)/bundle" ]; then \
		echo "Expected Ruby toolchain under $(RUBY_BIN_DIR)" >&2; \
		echo "Install it with: brew install ruby@3.3" >&2; \
		exit 1; \
	fi
	@export PATH="$(RUBY_BIN_DIR):$$PATH"; \
	export HOME="$(TMP_HOME)"; \
	mkdir -p "$$HOME"; \
	cd "$(ROOT_DIR)"; \
	echo "[1/4] Ruby: $$("$(RUBY_BIN_DIR)/ruby" --version)"; \
	echo "[2/4] Bundler: $$("$(RUBY_BIN_DIR)/bundle" _$(BUNDLER_VERSION)_ --version)"; \
	echo "[3/4] Installing gems"; \
	"$(RUBY_BIN_DIR)/bundle" _$(BUNDLER_VERSION)_ install; \
	echo "[4/4] Building Jekyll site"; \
	"$(RUBY_BIN_DIR)/bundle" _$(BUNDLER_VERSION)_ exec jekyll build --destination "$(OUTPUT_DIR)"; \
	echo; \
	echo "Local Pages build completed at:"; \
	echo "  $(OUTPUT_DIR)"
