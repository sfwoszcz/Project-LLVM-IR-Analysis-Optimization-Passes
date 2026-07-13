; SPDX-License-Identifier: MIT
;
; RUN: opt -load-pass-plugin %plugin \
; RUN:   -passes='safe-strength-reduction,verify' -S %s | FileCheck %s

define i32 @not_a_power_of_two(i32 %value) {
; CHECK-LABEL: define i32 @not_a_power_of_two(
; CHECK: %product = mul i32 %value, 3
entry:
  %product = mul i32 %value, 3
  ret i32 %product
}

define i32 @identity_factor(i32 %value) {
; CHECK-LABEL: define i32 @identity_factor(
; CHECK: %product = mul i32 %value, 1
entry:
  %product = mul i32 %value, 1
  ret i32 %product
}

define i32 @signed_wrap_flag(i32 %value) {
; CHECK-LABEL: define i32 @signed_wrap_flag(
; CHECK: %product = mul nsw i32 %value, 8
entry:
  %product = mul nsw i32 %value, 8
  ret i32 %product
}

define i32 @unsigned_wrap_flag(i32 %value) {
; CHECK-LABEL: define i32 @unsigned_wrap_flag(
; CHECK: %product = mul nuw i32 %value, 8
entry:
  %product = mul nuw i32 %value, 8
  ret i32 %product
}

define <4 x i32> @vector_value(<4 x i32> %value) {
; CHECK-LABEL: define <4 x i32> @vector_value(
; CHECK: %product = mul <4 x i32> %value,
entry:
  %product = mul <4 x i32> %value, <i32 8, i32 8, i32 8, i32 8>
  ret <4 x i32> %product
}
