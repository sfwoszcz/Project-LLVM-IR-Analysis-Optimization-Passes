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

#if __has_include("llvm/Plugins/PassPlugin.h")
#include "llvm/Plugins/PassPlugin.h"
#elif __has_include("llvm/Passes/PassPlugin.h")
#include "llvm/Passes/PassPlugin.h"
#else
#error "LLVM PassPlugin.h was not found"
#endif

namespace llvm_pass_lab {

llvm::PassPluginLibraryInfo getPluginInfo();

} // namespace llvm_pass_lab

#endif // LLVM_PASS_LAB_PLUGIN_H
