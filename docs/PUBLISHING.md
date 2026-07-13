# Publishing the repository

## Suggested repository name

```text
Project-LLVM-IR-Analysis-Optimization-Passes
```

## Suggested description

```text
C++17 LLVM new-pass-manager plugin with function metrics, conservative IR strength reduction, lit/FileCheck tests, x86-64/AArch64 code generation, CI, and secure coding documentation.
```

## Suggested topics

```text
llvm
clang
compiler
compiler-optimization
llvm-ir
cpp17
cmake
filecheck
embedded-systems
aarch64
x86-64
```

## Create and push

Create an empty public repository on GitHub without generating a README,
license, or `.gitignore`.

Then run from the extracted project directory:

```bash
git init
git branch -M main
git add .
git commit -m "Initial LLVM IR pass lab"
git remote add origin \
  git@github.com:sfwoszcz/Project-LLVM-IR-Analysis-Optimization-Passes.git
git push -u origin main
```

HTTPS can be used instead of SSH:

```bash
git remote add origin \
  https://github.com/sfwoszcz/Project-LLVM-IR-Analysis-Optimization-Passes.git
```

## Repository settings

Recommended settings:

- enable private vulnerability reporting;
- enable Dependabot alerts and security updates;
- require the CI workflow before merging;
- protect the `main` branch;
- require pull-request review;
- disallow force pushes to `main`;
- enable secret scanning where available;
- enable signed tags for releases.

## First verification

After the first push:

1. open the Actions tab;
2. inspect the LLVM installation step;
3. confirm the strict-warning build succeeds;
4. confirm all lit/FileCheck tests pass;
5. inspect the generated target-assembly step;
6. correct any LLVM-version-specific API or package issue before creating a
   release.

Do not add the project to the CV as completed until the first clean CI run has
passed and you can explain the implementation in an interview.
