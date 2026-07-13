#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -Eeuo pipefail
IFS=$'\n\t'

# shellcheck source=common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/common.sh"

readonly REQUESTED_BUILD_DIR="${BUILD_DIR}"
readonly RESOLVED_BUILD_DIR="$(realpath -m -- "${REQUESTED_BUILD_DIR}")"

case "${RESOLVED_BUILD_DIR}" in
  "${PROJECT_ROOT}"/*)
    ;;
  *)
    printf 'error: refusing to remove a path outside the project: %s\n' \
      "${RESOLVED_BUILD_DIR}" >&2
    exit 2
    ;;
esac

if [[ "${RESOLVED_BUILD_DIR}" == "${PROJECT_ROOT}" ]]; then
  printf 'error: refusing to remove the project root\n' >&2
  exit 2
fi

rm -rf -- "${RESOLVED_BUILD_DIR}"
printf 'removed: %s\n' "${RESOLVED_BUILD_DIR}"
