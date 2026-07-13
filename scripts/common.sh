#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -Eeuo pipefail
IFS=$'\n\t'

readonly PROJECT_ROOT="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1
  pwd -P
)"

LLVM_VERSION="${LLVM_VERSION:-22}"
BUILD_DIR="${BUILD_DIR:-${PROJECT_ROOT}/build}"

find_tool() {
  local base_name="$1"
  local versioned="${base_name}-${LLVM_VERSION}"

  if command -v -- "${versioned}" >/dev/null 2>&1; then
    command -v -- "${versioned}"
    return 0
  fi

  if command -v -- "${base_name}" >/dev/null 2>&1; then
    command -v -- "${base_name}"
    return 0
  fi

  printf 'error: required tool not found: %s or %s\n' \
    "${versioned}" "${base_name}" >&2
  return 127
}

find_plugin() {
  local candidate

  while IFS= read -r -d '' candidate; do
    printf '%s\n' "${candidate}"
    return 0
  done < <(
    find "${BUILD_DIR}" -maxdepth 4 -type f \
      \( -name 'LLVMIRPassLab.so' \
      -o -name 'LLVMIRPassLab.dylib' \
      -o -name 'LLVMIRPassLab.dll' \) \
      -print0
  )

  printf 'error: LLVMIRPassLab plugin not found under %s\n' \
    "${BUILD_DIR}" >&2
  return 1
}
