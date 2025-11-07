// RUN: CAL_ENABLE_JIT_CONSTEVAL=1 cal-opt --cal-const-eval %s | FileCheck %s

// Simple pure float helper that should be JIT-const-eval'd when called with constants.
func.func @twice_plus_half(%x: f32) -> f32 {
  %two  = arith.constant 2.000000e+00 : f32
  %half = arith.constant 5.000000e-01 : f32
  %y = arith.mulf %x, %two : f32
  %z = arith.addf %y, %half : f32
  func.return %z : f32
}

func.func @driver() -> f32 {
  %one = arith.constant 1.000000e+00 : f32
  %r = func.call @twice_plus_half(%one) : (f32) -> f32
  func.return %r : f32
}

cal.network @float_net() {
  %r = func.call @driver() : () -> f32
}

// CHECK-NOT: func.call @twice_plus_half
// CHECK: arith.constant 2.500000e+00 : f32
