// RUN: cal-opt %s --cal-network-elab=top=TopNet | FileCheck %s

// Two networks: TopNet (marked via pipeline option) references Nested via create_instance.
// DeadNet is unreachable and should be pruned by prune-unused-networks pass integrated post-finalize.

cal.network @Nested() {
  %c0 = arith.constant 0 : i32
}

cal.network @DeadNet() {
  %c1 = arith.constant 1 : i32
}

cal.actor @A() {
  cal.execution_body {
    %true = arith.constant 1 : i1
    cal.action_done %true : i1
  }
}

cal.network @TopNet() {
  cal.create_instance @Nested "nested0" ()
}

// CHECK: cal.network @TopNet
// CHECK: cal.network @Nested
// CHECK-NOT: cal.network @DeadNet
