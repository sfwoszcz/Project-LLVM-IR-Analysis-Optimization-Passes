# Design

## Goals

The project has four goals:

1. teach the LLVM pass-plugin structure;
2. demonstrate analysis and transformation passes;
3. make correctness arguments visible and reviewable;
4. provide portfolio-quality tests and documentation.

## Non-goals

The project does not attempt to outperform LLVM's production optimizers.

It does not automatically add its pass to Clang's default optimization
pipeline.

It does not claim that replacing multiplication by shifts is always profitable
on modern hardware.

## Pass granularity

Both passes are function passes.

This keeps the first implementation focused and allows direct registration in a
`FunctionPassManager`.

The analysis pass obtains loop information through the
`FunctionAnalysisManager`.

The transformation pass currently does not request analyses.

## Plugin registration

`Plugin.cpp` returns a `PassPluginLibraryInfo` record.

The registration callback adds a pipeline-parsing callback.

That callback recognizes two textual names:

```text
function-metrics
safe-strength-reduction
```

Unknown names return `false` so that other plugins or LLVM itself may handle
them.

## Function metrics

The pass counts structural elements by walking each basic block and instruction.

Loop counting uses `LoopAnalysis`.

Output is sent through LLVM's `raw_ostream` infrastructure.

The function name is printed using LLVM's operand printer rather than treated as
a shell or formatting string.

The output order and field order are deterministic.

## Strength-reduction match

The candidate must be a `BinaryOperator` with opcode `Instruction::Mul`.

The type must be a scalar integer.

One operand must be a `ConstantInt`.

The other operand must not also be a `ConstantInt`.

The APInt constant must contain exactly one set bit.

The factor one is excluded.

Wrap flags are excluded.

## Transformation legality

For an N-bit bit vector:

```text
x × 2^k mod 2^N
```

has the same resulting bit pattern as:

```text
x << k mod 2^N
```

for a representable shift amount `k` between zero and `N - 1`.

A nonzero single-bit N-bit constant always yields such a shift amount.

The pass uses the APInt bit pattern.

This means that an `i8` factor written as `-128` has bit pattern `10000000` and
is treated as `2^7`.

The unflagged operations have modular fixed-width semantics.

## Why wrap flags are skipped

`mul nsw` and `mul nuw` include stronger semantic promises.

Violating those promises creates poison.

A production transformation may be able to transfer the flags to `shl`.

This educational pass deliberately avoids making that proof implicit.

Negative tests confirm that flagged multiplications remain unchanged.

## Mutation safety

The pass walks instructions through `make_early_inc_range`.

The iterator advances before the current instruction may be erased.

A new `BinaryOperator` is inserted immediately before the old multiplication.

The new instruction receives:

- the old debug location;

The pass deliberately does not copy arbitrary metadata from `mul` to `shl`.
Metadata is instruction-sensitive, and preserving an unknown attachment without
proving that it remains valid can silently change optimizer assumptions.
- the old SSA name.

Uses are replaced before the old instruction is erased.

LLVM owns the instruction after insertion into the basic block.

No manual deletion is performed.

## Analysis preservation

The analysis pass returns `PreservedAnalyses::all()`.

The transformation pass returns `PreservedAnalyses::all()` when no candidate was
changed.

After any mutation, it returns `PreservedAnalyses::none()`.

The current implementation could preserve CFG-only analyses because it does not
change control flow.

Returning none is intentionally conservative.

## Test design

Positive tests cover:

- constant on the right;
- constant on the left;
- different integer widths;
- a high-bit constant.

Negative tests cover:

- non-power-of-two factors;
- identity factor one;
- signed wrap flags;
- unsigned wrap flags;
- vectors.

A composition test runs the transformation, metrics pass, and verifier in one
pipeline.

## Future design exercises

Useful extensions include:

- preserve CFG analyses after a successful rewrite;
- emit LLVM optimization remarks;
- handle splat vectors;
- prove and preserve `nuw` and `nsw`;
- use target-cost information;
- add an Alive2 model;
- register through a Clang pass-plugin pipeline hook.
