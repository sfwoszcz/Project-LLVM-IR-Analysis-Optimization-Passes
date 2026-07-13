# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.20)

project(
  LLVMIRPassLab
  VERSION 1.0.0
  DESCRIPTION "LLVM IR analysis and conservative optimization pass laboratory"
  LANGUAGES CXX
)

option(LLVM_PASS_LAB_WARNINGS_AS_ERRORS
       "Treat project compiler warnings as errors" OFF)
option(LLVM_PASS_LAB_BUILD_TESTS "Configure lit/FileCheck tests" ON)
option(LLVM_PASS_LAB_ENABLE_CLANG_TIDY
       "Run clang-tidy during compilation when available" OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(LLVM REQUIRED CONFIG)

if(LLVM_PACKAGE_VERSION VERSION_LESS 18.0)
  message(FATAL_ERROR
          "LLVM 18 or newer is required; found ${LLVM_PACKAGE_VERSION}")
endif()

if(LLVM_PACKAGE_VERSION VERSION_GREATER_EQUAL 23.0)
  message(WARNING
          "LLVM ${LLVM_PACKAGE_VERSION} is newer than the intended compatibility range of 18-22")
endif()

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "LLVM CMake directory: ${LLVM_DIR}")
message(STATUS "LLVM tools directory: ${LLVM_TOOLS_BINARY_DIR}")

list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")
include(AddLLVM)

# LLVM definitions and headers are part of the external SDK. Marking the
# headers SYSTEM prevents warnings in third-party headers from being promoted
# to errors by this project's strict warning policy.
add_definitions(${LLVM_DEFINITIONS})
include_directories(SYSTEM ${LLVM_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

add_llvm_pass_plugin(
  LLVMIRPassLab
  lib/FunctionMetrics.cpp
  lib/Plugin.cpp
  lib/SafeStrengthReduction.cpp
)

target_compile_features(LLVMIRPassLab PRIVATE cxx_std_17)

include(cmake/CompilerWarnings.cmake)
llvm_pass_lab_set_project_warnings(LLVMIRPassLab)

set_target_properties(
  LLVMIRPassLab
  PROPERTIES
    PREFIX ""
)

if(LLVM_PASS_LAB_ENABLE_CLANG_TIDY)
  find_program(CLANG_TIDY_EXECUTABLE
               NAMES clang-tidy-${LLVM_VERSION_MAJOR} clang-tidy)
  if(NOT CLANG_TIDY_EXECUTABLE)
    message(FATAL_ERROR "clang-tidy requested but not found")
  endif()
  set_target_properties(
    LLVMIRPassLab
    PROPERTIES
      CXX_CLANG_TIDY
        "${CLANG_TIDY_EXECUTABLE};--config-file=${CMAKE_SOURCE_DIR}/.clang-tidy"
  )
endif()

if(LLVM_PASS_LAB_BUILD_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif()
