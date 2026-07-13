# Verification

## Verification goals

The project should demonstrate:

- successful plugin compilation;
- successful dynamic loading by `opt`;
- deterministic analysis output;
- correct positive transformations;
- unchanged negative cases;
- valid transformed LLVM IR;
- pipeline composition;
- x86-64 and AArch64 lowering;
- clean formatting and static analysis.

## Build verification

```bash
cmake \
  -S . \
  -B build \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_COMPILER=clang++-22 \
  -DLLVM_DIR=/usr/lib/llvm-22/lib/cmake/llvm \
  -DLLVM_PASS_LAB_WARNINGS_AS_ERRORS=ON

cmake --build build --parallel
```

Expected result:

```text
Built target LLVMIRPassLab
```

The exact progress numbers and shared-library suffix vary by platform.

## Test matrix

| Test | Purpose |
|---|---|
| `Analysis/function-metrics.ll` | deterministic metrics and loop analysis |
| `Transforms/safe-strength-reduction.ll` | accepted scalar integer rewrites |
| `Transforms/safe-strength-reduction-negative.ll` | deliberately rejected cases |
| `Transforms/pipeline-composition.ll` | transformation, analysis, and verifier composition |

Run:

```bash
cmake --build build --target check-llvm-pass-lab
```

Expected summary:

```text
Testing Time: ...
  Passed: 4
```

The exact lit formatting depends on the installed version.

## CTest

```bash
ctest --test-dir build --output-on-failure
```

Expected result:

```text
100% tests passed, 0 tests failed
```

## Demo verification

```bash
BUILD_DIR="$PWD/build" LLVM_VERSION=22 ./scripts/run_demo.sh
```

Expected final line:

```text
demo: PASS
```

The demo intentionally checks that:

- multiplication by eight is transformed;
- multiplication by three remains a multiplication.

## IR verifier

Transformation tests include:

```text
-passes='safe-strength-reduction,verify'
```

This verifies the output after the custom transformation.

During development, a stronger diagnostic option is:

```bash
opt-22 \
  -load-pass-plugin build/LLVMIRPassLab.so \
  -passes='safe-strength-reduction' \
  -verify-each \
  -S \
  input.ll
```

## Target generation

```bash
BUILD_DIR="$PWD/build" LLVM_VERSION=22 \
  ./scripts/compare_targets.sh
```

Expected files:

```text
build/targets/x86_64.s
build/targets/aarch64.s
```

## Formatting

```bash
LLVM_VERSION=22 ./scripts/check_format.sh
```

Expected result:

```text
format check: PASS
```

## Static analysis

```bash
run-clang-tidy-22 \
  -p build \
  -header-filter='^.*/(include|lib)/.*'
```

Review every warning.

Do not suppress a warning without documenting why it is a false positive or an
intentional design choice.

## Release checklist

Before creating a release tag:

- [ ] clean configure from an empty build directory;
- [ ] warnings-as-errors build;
- [ ] lit/FileCheck tests pass;
- [ ] CTest passes;
- [ ] demo passes;
- [ ] x86-64 and AArch64 assembly files generate;
- [ ] clang-format passes;
- [ ] clang-tidy findings reviewed;
- [ ] README commands re-run;
- [ ] security policy reviewed;
- [ ] release notes updated;
- [ ] tag signed where possible.

## Current template validation note

The repository structure, source consistency, test expectations, shell syntax,
and archive contents can be reviewed without an LLVM development installation.

A release should not claim a successful LLVM build until CI or a local machine
with matching LLVM headers, libraries, `opt`, FileCheck, and lit has completed
the commands above.
