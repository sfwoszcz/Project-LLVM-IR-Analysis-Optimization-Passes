# SPDX-License-Identifier: MIT

import os
import shlex

import lit.formats
from lit.llvm import llvm_config

config.name = "LLVM-IR-Pass-Lab"
config.test_format = lit.formats.ShTest(execute_external=True)
config.suffixes = [".ll"]
config.excludes = ["CMakeLists.txt", "lit.cfg.py", "lit.site.cfg.py.in"]
config.test_source_root = config.llvm_pass_lab_source_root
config.test_exec_root = config.llvm_pass_lab_exec_root

plugin_path = os.environ.get("LLVM_PASS_LAB_PLUGIN")
if not plugin_path:
    lit_config.fatal("LLVM_PASS_LAB_PLUGIN is not set")

if not os.path.isfile(plugin_path):
    lit_config.fatal(f"pass plugin does not exist: {plugin_path}")

llvm_config.with_environment("PATH", config.llvm_tools_dir, append_path=True)
llvm_config.add_tool_substitutions(
    ["FileCheck", "not", "opt"],
    [config.llvm_tools_dir],
)

config.substitutions.append(("%plugin", shlex.quote(plugin_path)))
