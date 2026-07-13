; SPDX-License-Identifier: MIT
;
; RUN: opt -load-pass-plugin %plugin \
; RUN:   -passes='safe-strength-reduction,function-metrics,verify' \
; RUN:   -disable-output %s 2>&1 | FileCheck %s

; CHECK: [function-metrics] function=@pipeline basic_blocks=1 instructions=2 loads=0 stores=0 calls=0 branches=0 returns=1 phi_nodes=0 loops=0
define i32 @pipeline(i32 %value) {
entry:
  %product = mul i32 %value, 16
  ret i32 %product
}
