// RUN: cal-opt %s | FileCheck %s

// Simple actor to reference in instance/array types.
cal.actor @A() {
}

// CHECK-LABEL: cal.network @N
cal.network @N() {
  // CHECK: %[[ARR:.*]] = cal.instantiate_array @A count(4) : <@A, [4]>
  %arr = cal.instantiate_array @A count(4) : !cal.instance.array<@A, [4]>

  // CHECK: %[[C0:.*]] = arith.constant 0 : index
  %c0 = arith.constant 0 : index

  // CHECK: %[[H0:.*]] = cal.instance_at %[[ARR]][%[[C0]]] : !cal.instance.array<@A, [4]> -> !cal.instance<@A>
  %h0 = cal.instance_at %arr[%c0] : !cal.instance.array<@A, [4]> -> !cal.instance<@A>
}
