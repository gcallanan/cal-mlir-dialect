// RUN: cal-opt %s | FileCheck %s

// Minimal actor to provide a concrete entity symbol for instance handles.
cal.actor @A() {
  // Provide an execution body to make the actor well-formed when needed by passes.
  cal.execution_body {
    %false = arith.constant false
    cal.action_done %false : i1
  }
}

// Simple network using instance array init/set and instantiate.
cal.network @arr_net() {
  %h0 = cal.instantiate @A : <@A>
  %h1 = cal.instantiate @A : <@A>

  %arr0 = cal.instance.array.init : !cal.instance.array<@A, [2]>
  %c0 = arith.constant 0 : index
  %c1 = arith.constant 1 : index

  // Fill the array in two steps.
  %arr1 = cal.instance.array.set %arr0[%c0], %h0 : !cal.instance.array<@A, [2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2]>
  %arr2 = cal.instance.array.set %arr1[%c1], %h1 : !cal.instance.array<@A, [2]>, !cal.instance<@A> -> !cal.instance.array<@A, [2]>

  // CHECK: cal.instance.array.init : !cal.instance.array<@A, [2]>
  // CHECK: cal.instance.array.set
  // CHECK: cal.instance.array.set
}
