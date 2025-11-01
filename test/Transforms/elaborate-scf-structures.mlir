// RUN: cal-opt --elaborate-scf-structures %s | FileCheck %s

module {
  // CHECK-LABEL: cal.network @net_if
  // CHECK-NOT: scf.if
  // CHECK: fifo.print("Then\0A\00")
  cal.network @net_if() {
    %true = arith.constant true
    scf.if %true {
      fifo.print("Then\0A\00")
    } else {
      fifo.print("Else\0A\00")
    }
  }

  // CHECK-LABEL: cal.network @net_for
  // CHECK-NOT: scf.for
  // CHECK: fifo.print("Body\0A\00")
  // CHECK: fifo.print("Body\0A\00")
  // CHECK: fifo.print("Body\0A\00")
  cal.network @net_for() {
    %c0 = arith.constant 0 : index
    %c3 = arith.constant 3 : index
    %c1 = arith.constant 1 : index
    scf.for %i = %c0 to %c3 step %c1 {
      fifo.print("Body\0A\00")
      scf.yield
    }
  }
}
