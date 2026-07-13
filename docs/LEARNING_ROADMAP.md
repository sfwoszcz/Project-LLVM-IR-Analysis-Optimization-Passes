# Learning roadmap

This roadmap turns the repository into a structured compiler-development study
project.

## Phase 1: Toolchain orientation

Goals:

- identify Clang, `opt`, `llc`, FileCheck, and `llvm-lit`;
- generate textual IR and bitcode;
- round-trip between `.ll` and `.bc`;
- inspect version and target information.

Exercises:

```bash
clang-22 --version
opt-22 --version
llc-22 --version
llvm-config-22 --version

clang-22 -S -emit-llvm example.c -o example.ll
llvm-as-22 example.ll -o example.bc
llvm-dis-22 example.bc -o example.roundtrip.ll
```

Deliverable:

- a short note explaining each tool.

## Phase 2: Read LLVM IR

Goals:

- recognize functions, arguments, basic blocks, instructions, and terminators;
- understand typed values;
- trace def-use chains;
- identify loads, stores, and PHI nodes.

Exercises:

- annotate `examples/ir/handwritten.ll`;
- add a conditional branch;
- add a loop with two PHI nodes;
- run the verifier after every edit.

Deliverable:

- three valid hand-written IR examples.

## Phase 3: Understand the pass manager

Goals:

- understand pass granularity;
- understand analysis managers;
- understand preserved analyses;
- understand textual pipeline parsing.

Exercises:

- add a pass that prints opcode histograms;
- compose it with `function-metrics`;
- deliberately use an unknown pass name and inspect the diagnostic.

Deliverable:

- one new read-only pass with FileCheck tests.

## Phase 4: Prove a transformation

Goals:

- distinguish pattern matching from legality;
- reason about fixed-width integers;
- study `nuw`, `nsw`, poison, and undef;
- understand iterator-safe mutation.

Exercises:

- explain why factor one is excluded;
- add tests for `i16` and `i128`;
- add a test using the highest bit of an integer;
- add a negative test for two constant operands.

Deliverable:

- a written proof and a complete test matrix.

## Phase 5: Target code generation

Goals:

- compare target-independent IR with target-dependent output;
- recognize x86-64 and AArch64 shifts and addressing modes;
- inspect object files and symbols.

Exercises:

```bash
llc-22 -mtriple=x86_64-unknown-linux-gnu input.ll -o x86_64.s
llc-22 -mtriple=aarch64-unknown-linux-gnu input.ll -o aarch64.s
llc-22 -filetype=obj input.ll -o input.o
llvm-objdump-22 -d input.o
llvm-readelf-22 --all input.o
```

Deliverable:

- a comparison table explaining the generated instructions.

## Phase 6: Debugging

Goals:

- debug a dynamically loaded pass;
- inspect LLVM objects in GDB;
- understand assertions and verifier failures.

Exercises:

- set a breakpoint in `SafeStrengthReductionPass::run`;
- inspect the current `Instruction`;
- create an invalid hand-written IR test;
- read the verifier diagnostic and repair the IR.

Deliverable:

- a debugging guide with screenshots or terminal captures.

## Phase 7: Quality engineering

Goals:

- understand LLVM coding style;
- use clang-format and clang-tidy;
- maintain strict warnings;
- review CI security.

Exercises:

- add one clang-tidy rule and fix the findings;
- inspect the workflow token permissions;
- pin the Docker base image by digest;
- document a dependency-update process.

Deliverable:

- a verification report for one release tag.

## Phase 8: Advanced validation

Goals:

- study translation validation;
- understand optimization remarks;
- consider target profitability.

Exercises:

- model the transformation in Alive2;
- emit a remark for every transformed instruction;
- compare performance at `-O0`, `-O1`, and `-O2`;
- inspect whether LLVM's existing pipeline already canonicalizes the same code.

Deliverable:

- an engineering note explaining when the custom pass is educational rather
  than performance-improving.

## Phase 9: Upstream preparation

Goals:

- read LLVM's contribution process;
- identify an actual bug or missing test;
- prepare a minimal patch;
- communicate on LLVM Discourse or GitHub.

Exercises:

- reproduce an existing issue;
- reduce a test case;
- add a regression test;
- run the relevant LLVM test suite;
- submit only work that is genuinely useful upstream.

Deliverable:

- an upstream-quality patch or a documented issue analysis.
