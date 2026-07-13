// SPDX-License-Identifier: MIT
//===----------------------------------------------------------------------===//
//
// FunctionMetrics.cpp
//
// Implements a deterministic, read-only LLVM function analysis pass.
//
//===----------------------------------------------------------------------===//

#include "LLVMPassLab/FunctionMetrics.h"

#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/raw_ostream.h"

#include <cstdint>

using namespace llvm;

namespace llvm_pass_lab {
namespace {

struct FunctionMetrics {
  std::uint64_t BasicBlocks = 0;
  std::uint64_t Instructions = 0;
  std::uint64_t Loads = 0;
  std::uint64_t Stores = 0;
  std::uint64_t Calls = 0;
  std::uint64_t Branches = 0;
  std::uint64_t Returns = 0;
  std::uint64_t PhiNodes = 0;
  std::uint64_t Loops = 0;
};

std::uint64_t countLoops(const LoopInfo& LoopInformation) {
  SmallVector<const Loop*, 8> Worklist;
  for (const Loop* TopLevelLoop : LoopInformation)
    Worklist.push_back(TopLevelLoop);

  std::uint64_t Count = 0;
  while (!Worklist.empty()) {
    const Loop* Current = Worklist.pop_back_val();
    ++Count;

    for (const Loop* SubLoop : Current->getSubLoops())
      Worklist.push_back(SubLoop);
  }

  return Count;
}

FunctionMetrics collectMetrics(const Function& Function,
                               const LoopInfo& LoopInformation) {
  FunctionMetrics Metrics;
  Metrics.BasicBlocks = static_cast<std::uint64_t>(Function.size());
  Metrics.Loops = countLoops(LoopInformation);

  for (const BasicBlock& Block : Function) {
    for (const Instruction& Instruction : Block) {
      ++Metrics.Instructions;

      if (isa<LoadInst>(Instruction))
        ++Metrics.Loads;
      else if (isa<StoreInst>(Instruction))
        ++Metrics.Stores;

      if (isa<CallBase>(Instruction))
        ++Metrics.Calls;
      if (isa<BranchInst>(Instruction))
        ++Metrics.Branches;
      if (isa<ReturnInst>(Instruction))
        ++Metrics.Returns;
      if (isa<PHINode>(Instruction))
        ++Metrics.PhiNodes;
    }
  }

  return Metrics;
}

void printMetrics(const Function& Function, const FunctionMetrics& Metrics) {
  raw_ostream& Output = errs();

  Output << "[function-metrics] function=";
  Function.printAsOperand(Output, /*PrintType=*/false);
  Output << " basic_blocks=" << Metrics.BasicBlocks
         << " instructions=" << Metrics.Instructions
         << " loads=" << Metrics.Loads << " stores=" << Metrics.Stores
         << " calls=" << Metrics.Calls << " branches=" << Metrics.Branches
         << " returns=" << Metrics.Returns << " phi_nodes=" << Metrics.PhiNodes
         << " loops=" << Metrics.Loops << '\n';
}

} // namespace

PreservedAnalyses
FunctionMetricsPass::run(Function& Function,
                         FunctionAnalysisManager& AnalysisManager) {
  const LoopInfo& LoopInformation =
      AnalysisManager.getResult<LoopAnalysis>(Function);
  printMetrics(Function, collectMetrics(Function, LoopInformation));
  return PreservedAnalyses::all();
}

} // namespace llvm_pass_lab
