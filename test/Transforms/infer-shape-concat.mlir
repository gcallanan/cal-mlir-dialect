// RUN: cal-opt %s -infer-cal-instance-array-shape | FileCheck %s

cal.actor @A() {
  cal.execution_body { %t = arith.constant 1 : i1 cal.action_done %t : i1 }
}

// Build two static arrays (simulate already static via loops -> skipped here) then a dynamic concat result.
// To exercise concat upgrade we must have dynamic result type; emulate by casting through a temporary dynamic container.
cal.network @concat_wrapper() {
  // LHS dynamic init -> constant dims (2) so shape pass will staticize to length 2
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index
  %c2 = arith.constant 2 : index
  %initL = cal.instance.array.init(%c2 : index) : !cal.instance.array<@A, [?]>
  %lhs = scf.for %i = %c0 to %c2 step %c1 iter_args(%acc = %initL) -> !cal.instance.array<@A, [?]> {
    %h = cal.instantiate @A : !cal.instance<@A>
    %acc2 = cal.instance.array.set %acc[%i], %h : !cal.instance.array<@A, [?]>, !cal.instance<@A> -> !cal.instance.array<@A, [?]>
    scf.yield %acc2 : !cal.instance.array<@A, [?]>
  }
  // RHS dynamic init -> constant dims (3) so shape pass will staticize to length 3
  %c3 = arith.constant 3 : index
  %initR = cal.instance.array.init(%c3 : index) : !cal.instance.array<@A, [?]>
  %rhs = scf.for %j = %c0 to %c3 step %c1 iter_args(%accR = %initR) -> !cal.instance.array<@A, [?]> {
    %h2 = cal.instantiate @A : !cal.instance<@A>
    %accR2 = cal.instance.array.set %accR[%j], %h2 : !cal.instance.array<@A, [?]>, !cal.instance<@A> -> !cal.instance.array<@A, [?]>
    scf.yield %accR2 : !cal.instance.array<@A, [?]>
  }
  // Dynamic result concat expected to upgrade to length 5 (2 + 3)
  %concatDyn = cal.instance_array.concat %lhs, %rhs : !cal.instance.array<@A, [?]>, !cal.instance.array<@A, [?]> -> !cal.instance.array<@A, [?]>
}

// CHECK: cal.instance_array.concat
// CHECK: !cal.instance.array<@A, 5>
