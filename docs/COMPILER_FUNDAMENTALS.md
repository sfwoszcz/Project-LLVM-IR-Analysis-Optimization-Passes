# Compiler fundamentals

## 1. The source-to-binary pipeline

A conventional native compiler pipeline contains these broad stages:

```text
source
  ↓
preprocessing
  ↓
lexing and parsing
  ↓
abstract syntax tree
  ↓
semantic analysis
  ↓
intermediate representation
  ↓
target-independent optimization
  ↓
instruction selection
  ↓
register allocation and scheduling
  ↓
assembly or object code
  ↓
linking
  ↓
executable or shared library
```

Clang is the C, C++, Objective-C, and Objective-C++ frontend in the LLVM
ecosystem.

LLVM IR is the typed intermediate representation used by LLVM's middle end.

Target backends lower LLVM IR into machine-specific instructions.

The linker resolves symbols, applies relocations, combines sections, and
produces the final binary image.

## 2. Abstract syntax trees and LLVM IR

An abstract syntax tree represents source-language concepts.

Examples include:

- declarations;
- statements;
- expressions;
- types;
- templates;
- overload resolution;
- language-specific attributes.

LLVM IR is lower level.

It represents operations such as:

- integer and floating-point arithmetic;
- memory access;
- branches;
- calls;
- PHI nodes;
- casts;
- intrinsics.

Clang may lower many source-language constructs before LLVM optimization begins.

The middle end therefore does not generally operate on C++ classes, loops as
written, or source-level syntax.

It operates on control flow, values, types, memory effects, and metadata.

## 3. Static single assignment

LLVM IR is primarily in static single assignment form.

Each SSA value is defined once.

```llvm
%sum = add i32 %left, %right
%doubled = mul i32 %sum, 2
```

The name `%sum` identifies the result of one instruction.

It is not a mutable source-language variable.

When control-flow paths merge, a PHI node chooses a value based on the incoming
predecessor block.

```llvm
%result = phi i32 [ %from_left, %left_block ],
                  [ %from_right, %right_block ]
```

SSA makes def-use relationships explicit.

That helps analyses such as:

- constant propagation;
- dead-code elimination;
- value numbering;
- data-flow analysis;
- dominance reasoning.

## 4. Basic blocks and control-flow graphs

A basic block is a sequence of instructions with one entry and one terminating
control-transfer instruction.

Common terminators include:

- `ret`;
- `br`;
- `switch`;
- `invoke`;
- `unreachable`.

A function's basic blocks form a control-flow graph.

Edges represent possible transfers of control.

Many compiler analyses operate on the CFG:

- dominator trees;
- loop detection;
- reachability;
- post-dominance;
- liveness;
- data-flow equations.

## 5. LLVM types

LLVM IR is strongly typed.

Examples:

```llvm
i1
i8
i32
i64
float
double
ptr
<4 x i32>
{ i32, ptr }
```

Integer types are fixed-width bit vectors.

An `i32` value is not intrinsically signed or unsigned.

The instruction determines interpretation.

For example:

- `sdiv` is signed division;
- `udiv` is unsigned division;
- `icmp slt` is signed comparison;
- `icmp ult` is unsigned comparison.

This distinction matters when proving transformations.

## 6. Memory and registers

SSA values behave like virtual registers.

They are not memory locations.

Memory operations are explicit:

```llvm
%value = load i32, ptr %address, align 4
store i32 %value, ptr %destination, align 4
```

At low optimization levels, Clang may represent local variables using `alloca`,
`load`, and `store`.

The `mem2reg` pass promotes eligible stack slots into SSA values.

## 7. Undefined behavior, poison, and undef

Compiler correctness requires more than matching ordinary arithmetic examples.

LLVM IR distinguishes several difficult concepts.

### Undefined behavior

Some operations make the whole program undefined when their preconditions are
violated.

### Poison

A poison value may propagate through instructions and can trigger undefined
behavior when used by certain operations.

Flags such as `nsw` and `nuw` can create poison when overflow violates the
flag's promise.

### Undef

An `undef` value may independently choose an allowed value at each use.

LLVM's exact semantics evolve.

Always consult the language reference for the LLVM release being used.

## 8. Analysis and transformation passes

An analysis computes information without changing IR.

Examples:

- loop information;
- dominator trees;
- alias analysis;
- scalar evolution.

A transformation changes IR.

Examples:

- instruction combining;
- dead-code elimination;
- loop unrolling;
- inlining.

A transformation must report which analyses remain valid.

The safest conservative answer after a change is:

```cpp
llvm::PreservedAnalyses::none()
```

A read-only pass can return:

```cpp
llvm::PreservedAnalyses::all()
```

## 9. Frontend, middle end, and backend

### Frontend

The frontend understands source-language syntax and semantics.

Clang handles:

- tokens;
- parsing;
- type checking;
- templates;
- diagnostics;
- AST construction;
- lowering to LLVM IR.

### Middle end

The middle end analyzes and optimizes LLVM IR.

This repository operates here.

### Backend

The backend performs target-dependent work.

Examples:

- legalizing operations for the target;
- instruction selection;
- register allocation;
- scheduling;
- assembly printing;
- object emission.

LLVM's new pass manager is used by the optimization pipeline.

Parts of target-dependent code generation still use legacy pass-manager
infrastructure in LLVM 22.

## 10. Object files and linking

An object file commonly contains:

- machine code sections;
- data sections;
- symbol tables;
- relocation records;
- debug information;
- unwind information.

Useful LLVM tools include:

```bash
llvm-objdump
llvm-readelf
llvm-readobj
llvm-nm
llvm-size
llvm-dwarfdump
```

Linkers resolve references between object files and libraries.

They also lay out sections and apply relocations.

This is where compiler development connects directly to binary analysis.
