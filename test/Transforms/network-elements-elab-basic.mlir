// RUN: cal-opt %s -network-elements-elab --split-input-file | FileCheck %s

// CHECK-LABEL: module @M
module @M {
  // A simple constant if inside a network that should be folded by NetworkElementsElabPass.
  // The pass only folds scf.if with no results (network structural side-effects only).
  cal.network @test() {
  %true = arith.constant true
    scf.if %true {
      fifo.print("A\0A\00")
      scf.yield
    } else {
      fifo.print("B\0A\00")
      scf.yield
    }
  }
}
// CHECK: cal.network @test()
// CHECK: fifo.print("A\0A\00")
// CHECK-NOT: scf.if
