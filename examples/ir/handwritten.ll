; SPDX-License-Identifier: MIT
;
; A small hand-written LLVM IR module for experimentation.

define i32 @calculate(i32 %value) {
entry:
  %scaled = mul i32 %value, 8
  %result = add i32 %scaled, 4
  ret i32 %result
}
