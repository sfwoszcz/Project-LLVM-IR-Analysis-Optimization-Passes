# syntax=docker/dockerfile:1.7
# SPDX-License-Identifier: MIT

FROM ubuntu:24.04

ARG LLVM_VERSION=22
ARG DEBIAN_FRONTEND=noninteractive

ENV LLVM_VERSION="${LLVM_VERSION}"
ENV PATH="/usr/lib/llvm-${LLVM_VERSION}/bin:${PATH}"

WORKDIR /workspace

COPY scripts/bootstrap_ubuntu.sh /usr/local/bin/bootstrap_ubuntu.sh

RUN chmod 0755 /usr/local/bin/bootstrap_ubuntu.sh \
    && /usr/local/bin/bootstrap_ubuntu.sh \
    && rm -rf /var/lib/apt/lists/*

COPY . /workspace

RUN cmake \
      -S /workspace \
      -B /workspace/build \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CXX_COMPILER="clang++-${LLVM_VERSION}" \
      -DLLVM_DIR="/usr/lib/llvm-${LLVM_VERSION}/lib/cmake/llvm" \
      -DLLVM_PASS_LAB_WARNINGS_AS_ERRORS=ON \
    && cmake --build /workspace/build --parallel \
    && cmake --build /workspace/build --target check-llvm-pass-lab \
    && groupadd --gid 10001 llvmdev \
    && useradd --create-home --uid 10001 --gid 10001 --shell /usr/sbin/nologin llvmdev \
    && chown -R llvmdev:llvmdev /workspace

USER llvmdev

CMD ["cmake", "--build", "/workspace/build", "--target", "check-llvm-pass-lab"]
