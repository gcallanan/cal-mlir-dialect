// RUN: cal-opt %s | FileCheck %s

cal.interface @I

// CHECK-LABEL: cal.network @N
cal.network @N() {
  // CHECK: %[[ARR:.*]] = cal.instantiate_array.iface @I count(3) : <@I, 3>
  %arr = cal.instantiate_array.iface @I count(3) : !cal.instance.array.iface<@I, 3>

  %c1 = arith.constant 1 : index
  // CHECK: %[[H:.*]] = cal.instance_at %[[ARR]][%c1] : !cal.instance.array.iface<@I, 3>, index -> !cal.instance.iface<@I>
  %h = cal.instance_at %arr[%c1] : !cal.instance.array.iface<@I, 3>, index -> !cal.instance.iface<@I>
}
