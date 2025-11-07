// RUN: cal-opt --cal-const-eval --elaborate-scf-structures %s | FileCheck %s

module {
  // Helper: f(n) = 2*n + 1
  func.func @twice_plus_one(%n: index) -> index {
    %c1 = arith.constant 1 : index
    %two = arith.constant 2 : index
    %doubled = arith.muli %n, %two : index
    %res = arith.addi %doubled, %c1 : index
    func.return %res : index
  }

  // After const-eval, %ub becomes the constant 3 (for n=1),
  // and elaborate-scf-structures should remove the loop.
  // CHECK-LABEL: cal.network @use_twice_plus_one
  // CHECK-NOT: scf.for
  // CHECK: fifo.print("X\0A\00")
  // CHECK: fifo.print("X\0A\00")
  // CHECK: fifo.print("X\0A\00")
  cal.network @use_twice_plus_one() {
    %n1 = arith.constant 1 : index
    %ub = func.call @twice_plus_one(%n1) : (index) -> index

    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    scf.for %i = %c0 to %ub step %c1 {
      fifo.print("X\0A\00")
      scf.yield
    }
  }
}
