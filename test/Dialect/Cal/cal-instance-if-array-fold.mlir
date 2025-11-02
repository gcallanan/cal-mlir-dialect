// REQUIRES: legacy-ops
// RUN: cal-opt --resolve-instance-if %s | FileCheck %s

cal.actor @A() { }

cal.network @n() {
  %arr0 = cal.instantiate_array @A count(2) : !cal.instance.array<@A, 2>
  %arr1 = cal.instantiate_array @A count(2) : !cal.instance.array<@A, 2>

  %c_true = arith.constant true
  %res = cal.instance_if %c_true {
    cal.instance_yield %arr0 : !cal.instance.array<@A, 2>
  } else {
    cal.instance_yield %arr1 : !cal.instance.array<@A, 2>
  } : !cal.instance.array<@A, 2>

  // CHECK-LABEL: cal.network @n()
  // CHECK: cal.instantiate_array @A
  // CHECK-NOT: cal.instance_if
}
