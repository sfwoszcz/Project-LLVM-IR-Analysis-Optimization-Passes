# Secure coding and threat model

## Threat model

An LLVM pass plugin runs in the address space of `opt`, Clang, or another LLVM
tool.

A plugin crash terminates the host compiler process.

Memory corruption in a plugin can compromise the host process.

Crafted IR may attempt to trigger:

- invalid casts;
- iterator invalidation;
- excessive memory or CPU usage;
- malformed output;
- assertion failures;
- semantic miscompilation.

Build and CI infrastructure can also be attacked through:

- dependency substitution;
- malicious scripts;
- command injection;
- over-privileged workflow tokens;
- untrusted pull-request behavior;
- leaked credentials.

## Defensive C++ practices

### Narrow preconditions

The transformation accepts only a small, explicitly documented input class.

Unsupported instructions are left unchanged.

This is preferable to guessing at semantics.

### Checked LLVM casts

The code uses `dyn_cast` and validates null results.

It does not use `cast` where the type has not already been proven.

### Iterator-safe erasure

Instructions are traversed with `make_early_inc_range`.

This allows the current instruction to be removed safely.

### Ownership

LLVM owns instructions that have been inserted into a basic block.

The project does not manually delete IR objects.

It avoids raw owning pointers.

Raw pointers in the pass are non-owning LLVM references with short local
lifetimes.

### Metadata and debug information

The replacement instruction preserves the debug location so diagnostics and
source correlation remain useful. It deliberately does **not** copy arbitrary
metadata.

Metadata deserves care because some attachments affect optimization semantics
or are only valid on particular opcodes. New transformation types should copy
only metadata whose legality and meaning have been reviewed for the replacement
instruction.

### Analysis invalidation

The transformation returns no preserved analyses after a mutation.

This avoids reusing stale analysis results.

### Deterministic diagnostics

The metrics pass emits a fixed field order.

It uses LLVM output APIs.

Function identifiers are printed as LLVM operands.

### No external side effects

The plugin performs no:

- network access;
- subprocess execution;
- filesystem reads;
- environment-variable reads;
- dynamic configuration loading.

That keeps the compiler input boundary narrow.

## Defensive shell practices

All project shell scripts use:

```bash
set -Eeuo pipefail
IFS=$'\n\t'
```

Variables are quoted.

`eval` is not used.

Paths are passed as individual arguments.

Temporary input is not interpreted as shell code.

The scripts use versioned tool lookup without constructing a command string.

The cleanup script canonicalizes its target and refuses to delete paths outside
the project directory.

## Dependency installation

The Ubuntu bootstrap script:

- uses HTTPS;
- validates the requested LLVM major version;
- creates unpredictable temporary files and removes them with an exit trap;
- stores the apt key in a dedicated keyring;
- checks the complete expected fingerprint;
- restricts the repository with `signed-by`;
- installs explicit versioned package names;
- rejects unsupported Ubuntu codenames.

Review any root-level installation script before execution.

For higher-assurance environments, additionally pin:

- the container base image by digest;
- exact apt package versions;
- the LLVM release archive checksum;
- CMake and Ninja versions.

## CI hardening

The workflow sets:

```yaml
permissions:
  contents: read
```

The checkout action is pinned to a full commit SHA.

No write token or secret is required.

The workflow has a timeout.

Checkout credentials are not persisted because later steps do not push.

Shell steps use strict mode.

A production repository should also consider:

- branch protection;
- required reviews;
- signed commits or tags;
- Dependabot or equivalent update review;
- CodeQL where applicable;
- release provenance and attestations.

## Sanitizers

AddressSanitizer and UndefinedBehaviorSanitizer are valuable during development.

A dynamically loaded plugin and its host tool must be instrumented compatibly.

Loading an ASan-instrumented plugin into an ordinary `opt` process may fail
because the sanitizer runtime is not present in the host.

A robust sanitizer configuration therefore builds or runs a compatible
sanitized LLVM host.

The repository does not pretend that adding sanitizer flags only to the plugin
is a complete test.

## Resource exhaustion

The metrics pass is linear in the number of instructions plus loop nodes.

The transformation is linear in the number of instructions.

The project does not intentionally create repeated fixed-point rewrites.

However, LLVM IR can be very large.

Do not process untrusted IR with elevated privileges or without external CPU and
memory limits.

## Semantic security

Miscompilation is a security issue.

A transformation that changes program behavior may remove checks, corrupt
bounds, or alter cryptographic code.

Every transformation should include:

1. a precise legality rule;
2. negative tests;
3. verifier execution;
4. review of poison and undefined behavior;
5. target-independent reasoning;
6. differential or translation validation where possible.
