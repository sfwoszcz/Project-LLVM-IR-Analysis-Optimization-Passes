#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -Eeuo pipefail
IFS=$'\n\t'

# shellcheck source=common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

readonly OPT_BIN="$(find_tool opt)"
readonly LLC_BIN="$(find_tool llc)"
readonly PLUGIN_PATH="$(find_plugin)"
readonly INPUT_IR="${BUILD_DIR}/examples/strength_reduction.ll"
readonly OPTIMIZED_IR="${BUILD_DIR}/examples/strength_reduction.optimized.ll"
readonly OUTPUT_DIR="${BUILD_DIR}/targets"

"${PROJECT_ROOT}/scripts/generate_ir.sh"
mkdir -p -- "${OUTPUT_DIR}"

"${OPT_BIN}" \
  -load-pass-plugin "${PLUGIN_PATH}" \
  -passes='safe-strength-reduction,verify' \
  -S \
  "${INPUT_IR}" \
  -o "${OPTIMIZED_IR}"

"${LLC_BIN}" \
  -O2 \
  -mtriple=x86_64-unknown-linux-gnu \
  "${OPTIMIZED_IR}" \
  -o "${OUTPUT_DIR}/x86_64.s"

"${LLC_BIN}" \
  -O2 \
  -mtriple=aarch64-unknown-linux-gnu \
  "${OPTIMIZED_IR}" \
  -o "${OUTPUT_DIR}/aarch64.s"

printf 'generated:\n  %s\n  %s\n' \
  "${OUTPUT_DIR}/x86_64.s" \
  "${OUTPUT_DIR}/aarch64.s"
