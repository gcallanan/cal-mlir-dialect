// RUN: cal-opt -pass-pipeline='builtin.module(flatten-cal-networks{emit-stats})' %s 2>&1 | FileCheck %s --check-prefix=STATS
// RUN: cal-opt -pass-pipeline='builtin.module(flatten-cal-networks{emit-stats disable-pruning})' %s 2>&1 | FileCheck %s --check-prefix=STATS-NOPRUNE

// A small nested network to ensure at least one instance is flattened.
cal.network @Leaf() {
  %c0 = arith.constant 0 : i32
}

cal.network @Top() {
  cal.create_instance @Leaf "l" ()
}

// STATS: flatten-cal-networks stats:
// STATS-SAME: iterations=
// STATS-SAME: flattened_instances=
// STATS-SAME: pruned_networks=
// STATS-NOT: (pruning disabled)

// STATS-NOPRUNE: flatten-cal-networks stats:
// STATS-NOPRUNE-SAME: iterations=
// STATS-NOPRUNE-SAME: flattened_instances=
// STATS-NOPRUNE-SAME: pruned_networks=
// STATS-NOPRUNE-SAME: (pruning disabled)
