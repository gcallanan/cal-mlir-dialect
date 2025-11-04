// RUN: cal-opt -canonicalize -split-input-file %s | FileCheck %s

// Minimal actor entity to target with instantiate_array
cal.actor @A() {
}

// When count is a constant and the result type uses a dynamic extent ("?"),
// canonicalization should specialize the result to a static extent [2].
cal.network @Top() {
  // CHECK-LABEL: cal.network @Top
  // CHECK: cal.instantiate_array @A count(2) : <@A, [2]>
  %arr = cal.instantiate_array @A count(2) : !cal.instance.array<@A, [?]>
}

// -----

// Parameterized variant also specializes from [?] to [3].
cal.actor @B(%p0: i32) {
}

cal.network @Param() {
  %c7 = arith.constant 7 : i32
  // CHECK-LABEL: cal.network @Param
  // CHECK: cal.instantiate_array @B count(3) (%c7 : i32) : <@B, [3]>
  %arr = cal.instantiate_array @B count(3) (%c7 : i32) : !cal.instance.array<@B, [?]>
}
