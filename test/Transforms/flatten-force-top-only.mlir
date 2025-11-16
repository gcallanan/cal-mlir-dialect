// REQUIRES: cal-dialect
// Purpose: Ensure that specifying a top network (without any extra token)
//          causes the flatten-cal-networks pass to prune all non-top networks
//          by default (force-top-only behavior now implicit).
//
// We build a tiny module with three symbolic networks. The elaboration
// pipeline will currently accept them (they are trivial) and the flatten
// pass with the forced token should leave only @Top. The count of remaining
// networks must be 1.
//
// RUN: cal-opt %s -pass-pipeline='builtin.module(flatten-cal-networks{top=Top})' 2>&1 | FileCheck %s --check-prefix=FORCE
//
// FORCE: forced top pruning active; kept only 'Top'

module {
  // Non-top networks that should be pruned in forced mode.
  cal.network @A() {
    %c0 = arith.constant 0 : i32
  }
  cal.network @B() {
    %c1 = arith.constant 1 : i32
  }
  // Top network that must survive.
  cal.network @Top() {
    %c2 = arith.constant 2 : i32
  }
}
