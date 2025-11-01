// RUN: cal-opt --composite-fixed-point-pass="pipeline=cal-structural-elaboration" %s | FileCheck %s

module {
  // A tiny pure helper computing trip count: n + 2
  func.func @tripcount(%n: index) -> index {
    %c2 = arith.constant 2 : index
    %r = arith.addi %n, %c2 : index
    func.return %r : index
  }

  // After structural elaboration pipeline, the upper bound becomes a constant 3, and
  // elaborate-scf-structures should unroll the scf.for three times.
  // CHECK-LABEL: cal.network @use_tripcount
  // CHECK-NOT: scf.for
  // CHECK: fifo.print("B\0A\00")
  // CHECK: fifo.print("B\0A\00")
  // CHECK: fifo.print("B\0A\00")
  cal.network @use_tripcount() {
    %c1 = arith.constant 1 : index
    %ub = func.call @tripcount(%c1) : (index) -> index
    %c0 = arith.constant 0 : index
    %c1s = arith.constant 1 : index
    scf.for %i = %c0 to %ub step %c1s {
      fifo.print("B\0A\00")
      scf.yield
    }
  }
}
