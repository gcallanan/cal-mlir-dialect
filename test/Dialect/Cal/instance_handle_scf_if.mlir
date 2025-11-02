// RUN: cal-opt %s | FileCheck %s

// Check we can select between two handles using scf.if, without cal.instance_if.
// CHECK: scf.if
// CHECK-NOT: cal.instance_if

module {
  cal.actor @A() {
    cal.execution_body {
      %false = arith.constant false
      cal.action_done %false : i1
    }
  }

  cal.network @choose() {
    %true = arith.constant true

    %h = scf.if %true -> !cal.instance<@A> {
      %a0 = cal.instantiate @A : !cal.instance<@A>
      scf.yield %a0 : !cal.instance<@A>
    } else {
      %a1 = cal.instantiate @A : !cal.instance<@A>
      scf.yield %a1 : !cal.instance<@A>
    }
    // Optionally use %h later (omitted). The point is selecting a handle structurally.
  }
}
