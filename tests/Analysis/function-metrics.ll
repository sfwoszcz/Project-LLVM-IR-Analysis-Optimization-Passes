; SPDX-License-Identifier: MIT
;
; RUN: opt -load-pass-plugin %plugin -passes='function-metrics' \
; RUN:   -disable-output %s 2>&1 | FileCheck %s

; CHECK: [function-metrics] function=@leaf basic_blocks=1 instructions=4 loads=1 stores=0 calls=0 branches=0 returns=1 phi_nodes=0 loops=0
define i32 @leaf(i32 %value, ptr %source) {
entry:
  %loaded = load i32, ptr %source, align 4
  %scaled = mul i32 %value, 8
  %result = add i32 %loaded, %scaled
  ret i32 %result
}

; CHECK: [function-metrics] function=@counted_loop basic_blocks=4 instructions=9 loads=0 stores=0 calls=0 branches=3 returns=1 phi_nodes=2 loops=1
define i32 @counted_loop(i32 %limit) {
entry:
  br label %loop

loop:
  %index = phi i32 [ 0, %entry ], [ %next, %body ]
  %sum = phi i32 [ 0, %entry ], [ %updated, %body ]
  %condition = icmp slt i32 %index, %limit
  br i1 %condition, label %body, label %exit

body:
  %updated = add i32 %sum, %index
  %next = add i32 %index, 1
  br label %loop

exit:
  ret i32 %sum
}
