# Security policy

## Supported versions

This educational project supports the latest release on the `main` branch.
There are currently no long-term-support branches.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability that could expose
users or CI infrastructure.

Use GitHub's private vulnerability reporting feature when it is enabled for
the repository.
Otherwise, contact the repository owner privately through the contact method
listed on the GitHub profile.

Include:

- the affected commit or release;
- a minimal reproducer;
- expected and observed behavior;
- impact and preconditions;
- suggested remediation, when known.

## Scope

Security reports may concern:

- incorrect IR transformations that change program semantics;
- crashes or memory-safety issues triggered by crafted LLVM IR;
- command injection or unsafe path handling in scripts;
- CI or dependency-supply-chain weaknesses;
- accidental disclosure of secrets.

The pass plugin is an educational compiler-development project.
It is not a security boundary and should not process untrusted IR in a
privileged environment.
