#!/usr/bin/env bash
# SPDX-License-Identifier: MIT

set -Eeuo pipefail
IFS=$'\n\t'
umask 022

readonly LLVM_VERSION="${LLVM_VERSION:-22}"
readonly EXPECTED_FINGERPRINT="6084F3CF814B57C1CF12EFD515CF4D18AF4F7421"
readonly KEY_URL="https://apt.llvm.org/llvm-snapshot.gpg.key"
readonly KEYRING="/usr/share/keyrings/apt.llvm.org.gpg"

if [[ "${EUID}" -ne 0 ]]; then
  printf 'error: run this script as root or through sudo\n' >&2
  exit 1
fi

if [[ ! "${LLVM_VERSION}" =~ ^(18|19|20|21|22)$ ]]; then
  printf 'error: LLVM_VERSION must be an integer from 18 through 22\n' >&2
  exit 2
fi

. /etc/os-release

case "${VERSION_CODENAME:-}" in
  noble | jammy)
    ;;
  *)
    printf 'error: unsupported Ubuntu codename: %s\n' \
      "${VERSION_CODENAME:-unknown}" >&2
    exit 2
    ;;
esac

key_file="$(mktemp --tmpdir apt.llvm.org-key.XXXXXX.asc)"
keyring_file="$(mktemp --tmpdir apt.llvm.org-keyring.XXXXXX.gpg)"
cleanup() {
  rm -f -- "${key_file}" "${keyring_file}"
}
trap cleanup EXIT

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  cmake \
  curl \
  gnupg \
  ninja-build \
  python3

curl --fail --silent --show-error --location \
  --proto '=https' \
  --tlsv1.2 \
  "${KEY_URL}" \
  --output "${key_file}"

actual_fingerprint="$(
  gpg --batch --show-keys --with-colons "${key_file}" |
    awk -F: '$1 == "fpr" { print $10; exit }'
)"

if [[ "${actual_fingerprint}" != "${EXPECTED_FINGERPRINT}" ]]; then
  printf 'error: apt.llvm.org key fingerprint mismatch\n' >&2
  exit 3
fi

gpg --batch --dearmor --yes --output "${keyring_file}" "${key_file}"
install -o root -g root -m 0644 "${keyring_file}" "${KEYRING}"

cat >"/etc/apt/sources.list.d/apt.llvm.org.list" <<EOF_REPOSITORY
deb [signed-by=${KEYRING}] https://apt.llvm.org/${VERSION_CODENAME}/ llvm-toolchain-${VERSION_CODENAME}-${LLVM_VERSION} main
EOF_REPOSITORY

apt-get update
apt-get install -y --no-install-recommends \
  "clang-${LLVM_VERSION}" \
  "clang-format-${LLVM_VERSION}" \
  "clang-tidy-${LLVM_VERSION}" \
  "clang-tools-${LLVM_VERSION}" \
  "lld-${LLVM_VERSION}" \
  "llvm-${LLVM_VERSION}" \
  "llvm-${LLVM_VERSION}-dev" \
  "llvm-${LLVM_VERSION}-tools"

printf 'LLVM %s development environment installed\n' "${LLVM_VERSION}"
