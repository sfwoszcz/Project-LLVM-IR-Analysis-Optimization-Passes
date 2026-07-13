// SPDX-License-Identifier: MIT
//===----------------------------------------------------------------------===//
//
// SafeStrengthReduction.cpp
//
// Implements a deliberately conservative integer strength-reduction pass.
//
//===----------------------------------------------------------------------===//

#include "LLVMPassLab/SafeStrengthReduction.h"

#include "llvm/ADT/APInt.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Constants.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Type.h"

using namespace llvm;

namespace llvm_pass_lab {
namespace {

struct Candidate {
  BinaryOperator *Multiply = nullptr;
  Value *VariableOperand = nullptr;
  ConstantInt *Factor = nullptr;
};

Candidate findCandidate(Instruction &Instruction) {
  auto *Multiply = dyn_cast<BinaryOperator>(&Instruction);
  if (Multiply == nullptr || Multiply->getOpcode() != Instruction::Mul)
    return {};

  if (!Multiply->getType()->isIntegerTy())
    return {};

  // Poison semantics associated with wrap flags deserve separate proofs.
  // This introductory pass therefore handles only unflagged multiplication.
  if (Multiply->hasNoSignedWrap() || Multiply->hasNoUnsignedWrap())
    return {};

  ConstantInt *Factor = dyn_cast<ConstantInt>(Multiply->getOperand(1));
  Value *VariableOperand = Multiply->getOperand(0);

  if (Factor == nullptr) {
    Factor = dyn_cast<ConstantInt>(Multiply->getOperand(0));
    VariableOperand = Multiply->getOperand(1);
  }

  if (Factor == nullptr || isa<ConstantInt>(VariableOperand))
    return {};

  const APInt &FactorValue = Factor->getValue();
  if (!FactorValue.isPowerOf2() || FactorValue.isOne())
    return {};

  return {Multiply, VariableOperand, Factor};
}

bool replaceCandidate(const Candidate &Match) {
  if (Match.Multiply == nullptr || Match.VariableOperand == nullptr ||
      Match.Factor == nullptr)
    return false;

  const unsigned ShiftAmount = Match.Factor->getValue().logBase2();
  Constant *ShiftConstant =
      ConstantInt::get(Match.Multiply->getType(), ShiftAmount);

  auto *Shift = BinaryOperator::CreateShl(
      Match.VariableOperand, ShiftConstant, "", Match.Multiply->getIterator());

  // Preserve source correlation, but do not blindly copy arbitrary metadata:
  // not every metadata kind attached to `mul` is valid or meaningful on `shl`.
  Shift->setDebugLoc(Match.Multiply->getDebugLoc());
  Shift->takeName(Match.Multiply);

  Match.Multiply->replaceAllUsesWith(Shift);
  Match.Multiply->eraseFromParent();
  return true;
}

} // namespace

PreservedAnalyses SafeStrengthReductionPass::run(
    Function &Function, FunctionAnalysisManager &AnalysisManager) {
  (void)AnalysisManager;

  bool Changed = false;

  for (BasicBlock &Block : Function) {
    for (Instruction &Instruction : make_early_inc_range(Block))
      Changed |= replaceCandidate(findCandidate(Instruction));
  }

  return Changed ? PreservedAnalyses::none() : PreservedAnalyses::all();
}

} // namespace llvm_pass_lab
