// SPDX-License-Identifier: MIT
//===----------------------------------------------------------------------===//
//
// Plugin.cpp
//
// Registers the project passes with LLVM's new pass manager.
//
//===----------------------------------------------------------------------===//

#include "LLVMPassLab/Plugin.h"

#include "LLVMPassLab/FunctionMetrics.h"
#include "LLVMPassLab/SafeStrengthReduction.h"

#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Config/llvm-config.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/Support/Compiler.h"

using namespace llvm;

namespace llvm_pass_lab {

PassPluginLibraryInfo getPluginInfo() {
  return {
      LLVM_PLUGIN_API_VERSION,
      "LLVMIRPassLab",
      LLVM_VERSION_STRING,
      [](PassBuilder& Builder) {
        Builder.registerPipelineParsingCallback(
            [](StringRef Name, FunctionPassManager& FunctionPasses,
               ArrayRef<PassBuilder::PipelineElement>) {
              if (Name == "function-metrics") {
                FunctionPasses.addPass(FunctionMetricsPass());
                return true;
              }

              if (Name == "safe-strength-reduction") {
                FunctionPasses.addPass(SafeStrengthReductionPass());
                return true;
              }

              return false;
            });
      },
  };
}

} // namespace llvm_pass_lab

extern "C" LLVM_ATTRIBUTE_WEAK PassPluginLibraryInfo llvmGetPassPluginInfo() {
  return llvm_pass_lab::getPluginInfo();
}
