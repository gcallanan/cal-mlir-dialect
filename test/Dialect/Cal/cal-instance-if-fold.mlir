// RUN: cal-opt --resolve-instance-if %s | FileCheck %s

cal.actor @A() { }

cal.network @n() {
  %hA = cal.instantiate @A : !cal.instance<@A>
  %hA2 = cal.instantiate @A : !cal.instance<@A>

  %c_true = arith.constant true
  %res = cal.instance_if %c_true {
    cal.instance_yield %hA : !cal.instance<@A>
  } else {
    cal.instance_yield %hA2 : !cal.instance<@A>
  } : !cal.instance<@A>

  // CHECK-LABEL: cal.network @n()
  // CHECK: cal.instantiate @A
  // CHECK-NOT: cal.instance_if
}
