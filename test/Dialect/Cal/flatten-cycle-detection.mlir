// RUN: cal-opt --flatten-cal-networks -split-input-file %s -verify-diagnostics

// Self-recursive network should trigger cycle detection.
cal.network @Self() {
  // expected-error@-1 {{cycle detected in cal.network hierarchy}}
  cal.create_instance @Self "s" ()
}

// -----

// Non-cyclic nesting (control): A instantiates B, B instantiates C, no back edge.
cal.network @C() {
  %c0 = arith.constant 0 : i32
}

cal.network @B() {
  cal.create_instance @C "c" ()
}

cal.network @A() {
  cal.create_instance @B "b" ()
}
