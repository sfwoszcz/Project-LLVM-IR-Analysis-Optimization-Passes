# SPDX-License-Identifier: MIT

find_program(
  LLVM_LIT_EXECUTABLE
  NAMES llvm-lit-${LLVM_VERSION_MAJOR} llvm-lit lit
  HINTS "${LLVM_TOOLS_BINARY_DIR}"
)

if(NOT LLVM_LIT_EXECUTABLE)
  message(FATAL_ERROR
          "LLVM lit was not found. Install llvm-${LLVM_VERSION_MAJOR}-tools "
          "or provide LLVM_LIT_EXECUTABLE.")
endif()

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.site.cfg.py.in
  ${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg.py
  @ONLY
)

add_custom_target(
  check-llvm-pass-lab
  COMMAND
    ${CMAKE_COMMAND} -E env
    "LLVM_PASS_LAB_PLUGIN=$<TARGET_FILE:LLVMIRPassLab>"
    ${LLVM_LIT_EXECUTABLE} -sv ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS LLVMIRPassLab
  USES_TERMINAL
)

add_test(
  NAME llvm-pass-lab-lit
  COMMAND
    ${CMAKE_COMMAND} -E env
    "LLVM_PASS_LAB_PLUGIN=$<TARGET_FILE:LLVMIRPassLab>"
    ${LLVM_LIT_EXECUTABLE} -sv ${CMAKE_CURRENT_BINARY_DIR}
)
