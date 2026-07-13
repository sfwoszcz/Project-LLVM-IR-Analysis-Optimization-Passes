#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -Eeuo pipefail
IFS=$'\n\t'

# shellcheck source=common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

readonly CLANG_BIN="$(find_tool clang)"
readonly INPUT_FILE="${1:-${PROJECT_ROOT}/examples/c/strength_reduction.c}"
readonly OUTPUT_DIR="${2:-${BUILD_DIR}/examples}"

mkdir -p -- "${OUTPUT_DIR}"

"${CLANG_BIN}" \
  -S \
  -emit-llvm \
  -O0 \
  -Xclang -disable-O0-optnone \
  -Wall \
  -Wextra \
  -Wpedantic \
  "${INPUT_FILE}" \
  -o "${OUTPUT_DIR}/strength_reduction.ll"

printf 'generated: %s\n' "${OUTPUT_DIR}/strength_reduction.ll"
