# SPDX-License-Identifier: MIT

function(llvm_pass_lab_set_project_warnings target_name)
  if(MSVC)
    set(project_warnings
        /W4
        /permissive-
        /w14242
        /w14254
        /w14263
        /w14265
        /w14287
        /we4289
        /w14296
        /w14311
        /w14545
        /w14546
        /w14547
        /w14549
        /w14555
        /w14619
        /w14640
        /w14826
        /w14905
        /w14906
        /w14928)
  else()
    set(project_warnings
        -Wall
        -Wextra
        -Wpedantic
        -Wconversion
        -Wsign-conversion
        -Wshadow
        -Wformat=2
        -Wnull-dereference
        -Wdouble-promotion)
  endif()

  if(LLVM_PASS_LAB_WARNINGS_AS_ERRORS)
    if(MSVC)
      list(APPEND project_warnings /WX)
    else()
      list(APPEND project_warnings -Werror)
    endif()
  endif()

  target_compile_options(${target_name} PRIVATE ${project_warnings})
endfunction()
