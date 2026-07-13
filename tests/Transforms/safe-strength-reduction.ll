; SPDX-License-Identifier: MIT
;
; RUN: opt -load-pass-plugin %plugin \
; RUN:   -passes='safe-strength-reduction,verify' -S %s | FileCheck %s

define i32 @constant_on_right(i32 %value) {
; CHECK-LABEL: define i32 @constant_on_right(
; CHECK: %product = shl i32 %value, 3
; CHECK-NOT: mul i32
entry:
  %product = mul i32 %value, 8
  ret i32 %product
}

define i64 @constant_on_left(i64 %value) {
; CHECK-LABEL: define i64 @constant_on_left(
; CHECK: %product = shl i64 %value, 5
; CHECK-NOT: mul i64
entry:
  %product = mul i64 32, %value
  ret i64 %product
}

define i8 @high_bit_factor(i8 %value) {
; CHECK-LABEL: define i8 @high_bit_factor(
; CHECK: %product = shl i8 %value, 7
; CHECK-NOT: mul i8
entry:
  %product = mul i8 %value, -128
  ret i8 %product
}
