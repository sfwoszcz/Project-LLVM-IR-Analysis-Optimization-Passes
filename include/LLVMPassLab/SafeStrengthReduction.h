// SPDX-License-Identifier: MIT
//===----------------------------------------------------------------------===//
//
// SafeStrengthReduction.h
//
// Declares a conservative LLVM IR transformation pass.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_PASS_LAB_SAFE_STRENGTH_REDUCTION_H
#define LLVM_PASS_LAB_SAFE_STRENGTH_REDUCTION_H

#include "llvm/IR/PassManager.h"

namespace llvm_pass_lab {

/// Replaces a narrowly defined class of integer multiplications with shifts.
///
/// The pass transforms only unflagged scalar integer `mul` instructions where
/// exactly one operand is a single-bit integer constant other than one. It
/// intentionally skips vector operations and `nuw`/`nsw` instructions.
class SafeStrengthReductionPass
    : public llvm::PassInfoMixin<SafeStrengthReductionPass> {
public:
  llvm::PreservedAnalyses
  run(llvm::Function &Function,
      llvm::FunctionAnalysisManager &AnalysisManager);
};

} // namespace llvm_pass_lab

#endif // LLVM_PASS_LAB_SAFE_STRENGTH_REDUCTION_H
