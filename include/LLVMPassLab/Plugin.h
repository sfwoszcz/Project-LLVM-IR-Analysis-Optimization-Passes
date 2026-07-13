// SPDX-License-Identifier: MIT
//===----------------------------------------------------------------------===//
//
// Plugin.h
//
// Declares the pass-plugin registration entry point used by LLVM tools.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_PASS_LAB_PLUGIN_H
#define LLVM_PASS_LAB_PLUGIN_H

#include "llvm/Passes/PassPlugin.h"

namespace llvm_pass_lab {

llvm::PassPluginLibraryInfo getPluginInfo();

} // namespace llvm_pass_lab

#endif // LLVM_PASS_LAB_PLUGIN_H
