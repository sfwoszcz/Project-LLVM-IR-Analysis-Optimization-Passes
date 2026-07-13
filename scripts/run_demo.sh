#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -Eeuo pipefail
IFS=$'\n\t'

# shellcheck source=common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

readonly OPT_BIN="$(find_tool opt)"
readonly FILECHECK_BIN="$(find_tool FileCheck)"
readonly PLUGIN_PATH="$(find_plugin)"
readonly INPUT_IR="${BUILD_DIR}/examples/strength_reduction.ll"
readonly OUTPUT_IR="${BUILD_DIR}/examples/strength_reduction.optimized.ll"

"${PROJECT_ROOT}/scripts/generate_ir.sh"

printf '\n== Function metrics ==\n'
"${OPT_BIN}" \
  -load-pass-plugin "${PLUGIN_PATH}" \
  -passes='function-metrics' \
  -disable-output \
  "${INPUT_IR}"

printf '\n== Conservative strength reduction ==\n'
"${OPT_BIN}" \
  -load-pass-plugin "${PLUGIN_PATH}" \
  -passes='safe-strength-reduction,verify' \
  -S \
  "${INPUT_IR}" \
  -o "${OUTPUT_IR}"

grep -nE 'define|mul|shl|ret' "${OUTPUT_IR}" || true

printf '\n== Smoke assertion ==\n'
cat >"${BUILD_DIR}/examples/demo.check" <<'CHECK'
; CHECK: shl i32
; CHECK: mul i32
CHECK

"${FILECHECK_BIN}" \
  "${BUILD_DIR}/examples/demo.check" \
  <"${OUTPUT_IR}"

printf '\ndemo: PASS\n'
