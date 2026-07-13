# SPDX-License-Identifier: MIT

BUILD_DIR ?= build
BUILD_TYPE ?= Debug
LLVM_VERSION ?= 22
LLVM_DIR ?= /usr/lib/llvm-$(LLVM_VERSION)/lib/cmake/llvm
CXX ?= clang++-$(LLVM_VERSION)

.PHONY: all configure build test demo format-check tidy clean docker

all: test

configure:
	cmake -S . -B $(BUILD_DIR) -G Ninja \
		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
		-DCMAKE_CXX_COMPILER=$(CXX) \
		-DLLVM_DIR=$(LLVM_DIR) \
		-DLLVM_PASS_LAB_WARNINGS_AS_ERRORS=ON

build: configure
	cmake --build $(BUILD_DIR) --parallel

test: build
	cmake --build $(BUILD_DIR) --target check-llvm-pass-lab
	ctest --test-dir $(BUILD_DIR) --output-on-failure

demo: build
	LLVM_VERSION=$(LLVM_VERSION) BUILD_DIR=$(BUILD_DIR) ./scripts/run_demo.sh

format-check:
	./scripts/check_format.sh

tidy: configure
	cmake --build $(BUILD_DIR) --target LLVMIRPassLab

docker:
	docker build --build-arg LLVM_VERSION=$(LLVM_VERSION) \
		-t llvm-ir-pass-lab:$(LLVM_VERSION) .

clean:
	BUILD_DIR="$(BUILD_DIR)" ./scripts/clean.sh
