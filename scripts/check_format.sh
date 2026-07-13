#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -Eeuo pipefail
IFS=$'\n\t'

# shellcheck source=common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

readonly CLANG_FORMAT_BIN="$(find_tool clang-format)"

mapfile -d '' SOURCES < <(
  find \
    "${PROJECT_ROOT}/include" \
    "${PROJECT_ROOT}/lib" \
    "${PROJECT_ROOT}/examples" \
    -type f \
    \( -name '*.h' -o -name '*.c' -o -name '*.cc' -o -name '*.cpp' \) \
    -print0
)

if ((${#SOURCES[@]} == 0)); then
  printf 'error: no source files found\n' >&2
  exit 1
fi

"${CLANG_FORMAT_BIN}" --dry-run --Werror "${SOURCES[@]}"
printf 'format check: PASS\n'
