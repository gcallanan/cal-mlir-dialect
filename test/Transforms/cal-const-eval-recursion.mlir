// RUN: CAL_EVAL_MAX_DEPTH=4 CAL_ENABLE_JIT_CONSTEVAL=1 cal-opt --cal-const-eval %s | FileCheck %s --check-prefix=NO-FOLD
// RUN: CAL_EVAL_MAX_DEPTH=64 CAL_ENABLE_JIT_CONSTEVAL=1 cal-opt --cal-const-eval %s | FileCheck %s --check-prefix=FOLD
// RUN: CAL_ENABLE_JIT_CONSTEVAL=1 CAL_JIT_ALLOW_RECURSION=1 cal-opt --cal-const-eval %s | FileCheck %s --check-prefix=JIT-RECURSE

// A tiny recursive helper: sum_down(n) = (n==0) ? 0 : n + sum_down(n-1)
// Interpreter path should fold for small n when depth limit permits.
// JIT path (without CAL_JIT_ALLOW_RECURSION) skips due to self recursion.

// Recursive helper: sum_down(n) = n + sum_down(n-1), sum_down(0) = 0
func.func @sum_down(%n: i32) -> i32 {
  %zero = arith.constant 0 : i32
  %is0 = arith.cmpi eq, %n, %zero : i32
  %res = arith.select %is0, %zero, %n : i32
  // Recursive part: if n!=0 then call sum_down(n-1) and add
  %one = arith.constant 1 : i32
  %n_minus_1 = arith.subi %n, %one : i32
  %cond = arith.cmpi ne, %n, %zero : i32
  %rec = func.call @sum_down(%n_minus_1) : (i32) -> i32
  %sum = arith.addi %res, %rec : i32
  func.return %sum : i32
}

// Driver: call with constant 4.
// Driver function calls sum_down(4).
func.func @drive() -> i32 {
  %c4 = arith.constant 4 : i32
  %r = func.call @sum_down(%c4) : (i32) -> i32
  func.return %r : i32
}

// Anchor network to keep functions reachable for pruning/DCE logic.
cal.network @test_net() {
  %val = func.call @drive() : () -> i32
  // We do not print %val; presence ensures external root so drive and sum_down are retained for inspection.
}

// NO-FOLD: interpreter depth limit (4) blocks full recursion => inner func.call @sum_down should remain.
// NO-FOLD: CHECK: func.call @sum_down

// FOLD: full depth allows folding => inner call removed and constant 10 present.
// FOLD: CHECK-NOT: func.call @sum_down
// FOLD: CHECK: arith.constant 10 : i32

// JIT-RECURSE: with CAL_JIT_ALLOW_RECURSION allowed, still expect folding to constant (interpreter or JIT) -> 10.
// JIT-RECURSE: CHECK: arith.constant 10 : i32
