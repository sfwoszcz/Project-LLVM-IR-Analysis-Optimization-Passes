# Contributing

Contributions should be small, reviewable, tested, and documented.

## Development rules

1. Build with a supported LLVM release in the 18-22 range.
2. Preserve LLVM IR semantics.
3. Add a positive and a negative FileCheck test for each transformation.
4. Run `verify` after transformation tests.
5. Keep source files formatted with the repository `.clang-format`.
6. Avoid unchecked casts, ownership ambiguity, shell `eval`, and unquoted
   expansions.
7. Explain why a transformation is legal, including poison and overflow
   behavior.
8. Keep documentation one sentence per line where practical.

## Before submitting a change

```bash
./scripts/check_format.sh
./scripts/test.sh
BUILD_DIR="$PWD/build" ./scripts/run_demo.sh
```

For a new transformation, document:

- the exact match conditions;
- the proof of semantic equivalence;
- deliberately unsupported cases;
- preserved or invalidated analyses;
- target-independent and target-specific tests.
