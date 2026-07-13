// SPDX-License-Identifier: MIT
//===----------------------------------------------------------------------===//
//
// FunctionMetrics.h
//
// Declares a read-only LLVM function pass that emits deterministic structural
// metrics for each function.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_PASS_LAB_FUNCTION_METRICS_H
#define LLVM_PASS_LAB_FUNCTION_METRICS_H

#include "llvm/IR/PassManager.h"

namespace llvm_pass_lab {

/// Collects and prints deterministic structural metrics for each function.
///
/// The pass does not mutate LLVM IR and therefore preserves all analyses.
class FunctionMetricsPass : public llvm::PassInfoMixin<FunctionMetricsPass> {
public:
  llvm::PreservedAnalyses run(llvm::Function& Function,
                              llvm::FunctionAnalysisManager& AnalysisManager);
};

} // namespace llvm_pass_lab

#endif // LLVM_PASS_LAB_FUNCTION_METRICS_H
