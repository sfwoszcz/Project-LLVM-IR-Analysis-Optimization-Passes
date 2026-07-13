#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -Eeuo pipefail
IFS=$'\n\t'

# shellcheck source=common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

readonly CMAKE_BIN="$(find_tool cmake)"
readonly CTEST_BIN="$(find_tool ctest)"

"${PROJECT_ROOT}/scripts/build.sh"
"${CMAKE_BIN}" --build "${BUILD_DIR}" --target check-llvm-pass-lab
"${CTEST_BIN}" --test-dir "${BUILD_DIR}" --output-on-failure
