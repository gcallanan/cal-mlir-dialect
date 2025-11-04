// RUN: cal-opt -split-input-file %s -verify-diagnostics

// Actor with one parameter to ensure entity symbol resolution works.
cal.actor @B(%p0: i32) {
}

// Static result type extent [3] must match count(2) -> error
cal.network @Bad() {
  %c1 = arith.constant 1 : i32
  // expected-error @+1 {{static result type extent [3] does not match count(2)}}
  %arr = cal.instantiate_array @B count(2) (%c1 : i32) : !cal.instance.array<@B, [3]>
}
