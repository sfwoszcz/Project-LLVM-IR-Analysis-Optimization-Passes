#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -Eeuo pipefail
IFS=$'\n\t'

# shellcheck source=common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

readonly CMAKE_BIN="$(find_tool cmake)"
readonly NINJA_BIN="$(find_tool ninja)"
readonly CXX_BIN="${CXX:-$(find_tool clang++)}"
readonly LLVM_DIR="${LLVM_DIR:-/usr/lib/llvm-${LLVM_VERSION}/lib/cmake/llvm}"
readonly BUILD_TYPE="${BUILD_TYPE:-Debug}"

"${CMAKE_BIN}" \
  -S "${PROJECT_ROOT}" \
  -B "${BUILD_DIR}" \
  -G Ninja \
  -DCMAKE_MAKE_PROGRAM="${NINJA_BIN}" \
  -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" \
  -DCMAKE_CXX_COMPILER="${CXX_BIN}" \
  -DLLVM_DIR="${LLVM_DIR}" \
  -DLLVM_PASS_LAB_WARNINGS_AS_ERRORS=ON

"${CMAKE_BIN}" --build "${BUILD_DIR}" --parallel
