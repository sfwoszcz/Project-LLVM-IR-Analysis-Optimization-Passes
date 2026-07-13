## Summary

Explain what changed and why.

## Correctness

Describe the semantic argument for any IR transformation.

Include treatment of:

- integer width and signedness;
- overflow and poison;
- `undef` and poison operands;
- metadata legality and debug locations;
- analysis preservation;
- unsupported cases.

## Verification

- [ ] strict-warning build passes
- [ ] positive FileCheck test added or updated
- [ ] negative FileCheck test added or updated
- [ ] verifier included after IR mutation
- [ ] formatting passes
- [ ] clang-tidy findings reviewed
- [ ] documentation updated
