# User optional area
# DEBUG option
DBG_MAKEFILE ?=
ifeq ($(DBG_MAKEFILE),1)
    $(warning ***** $(shell date)) 
    $(warning ***** starting Makefile for goal(s) "$(MAKECMDGOALS)")
else
    # If we're not debugging the Makefile, don't echo recipes.
    MAKEFLAGS += -s
endif

# Support platform
ALL_PLATFORM ?= linux/amd64 linux/arm64


# Program version
VERSION ?= $(shell git describe --tags --always --dirty)

# Go env setting 
GOFLAGS ?=
HTTP_PROXY ?=	
HTTPS_PROXY ?=
GOFLAGS := $(GOFLAGS) -modcacherw

# Fix area
# We don't need make's built-in rules.
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
.SUFF	IXES:

# Get the OS and ARCH in this system
OS := $(if $(GOOS),$(GOOS),$(shell go env GOOS))
ARCH := $(if $(GOARCH),$(GOARCH),$(shell go env GOARCH))

# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /usr/bin/env bash -o errexit -o pipefail -o nounset
BUILDX_NAME := $(shell basename $$(pwd))

## make command
all:
all: build install

# 定义变量
BUILD_DIR = bin/linux_amd64
# 获取所有应用程序目录
APP_DIRS := $(wildcard cmd/*)
# 获取每个应用程序的名称
APP_NAMES := $(notdir $(APP_DIRS))
# 构建命令
build: $(APP_NAMES)
$(APP_NAMES):
	echo "Building $@..."
	go build -o $(BUILD_DIR)/$@ ./cmd/$@/main.go

install: build
	echo "Install ...."
	mkdir -p /usr/local/bin
	cp $(addprefix $(BUILD_DIR)/,$(APP_NAMES)) /usr/local/bin/


test:
test:

lint: # @HELP runs golangci-lint
lint: | $(BUILD_DIRS)

version: # @HELP outputs the version string
version:
	echo $(VERSION)

clean: # @HELP removes built binaries and temporary files
clean: bin-clean install-clean

bin-clean:
	test -d bin && chmod -R u+w bin || true
	echo "Cleaning ./bin"
	rm -rf bin

install-clean:
	for bin in $(APP_NAMES); do \
		echo "Cleaning /usr/local/bin/$$bin..."; \
        rm -f /usr/local/bin/$$bin; \
    done

help: # @HELP prints this message
help:
	echo "VARIABLES:"
	echo "  BINS = $(BINS)"
	echo "  OS = $(OS)"
	echo "  ARCH = $(ARCH)"
	echo "  DBG = $(DBG)"
	echo "  GOFLAGS = $(GOFLAGS)"
	echo "  REGISTRY = $(REGISTRY)"
	echo
	echo "TARGETS:"
	grep -E '^.*: *# *@HELP' $(MAKEFILE_LIST)     \
	    | awk '                                   \
	        BEGIN {FS = ": *# *@HELP"};           \
	        { printf "  %-30s %s\n", $$1, $$2 };  \
	    '

