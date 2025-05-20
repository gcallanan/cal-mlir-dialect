//===- CalPsss.td - Cal dialect passes -------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef CAL_PASS
#define CAL_PASS

include "mlir/Pass/PassBase.td"

def LowerCalStateToMemref: Pass<"lower-cal-state-to-memref"> {
  let summary = "Lower CAL state operations to MemRef dialect operations";
  let description = [{
    This pass lowers state-related operations from the CAL dialect, specifically
    `cal.state`, `cal.get`, and `cal.set`, to equivalent operations in the MemRef
    dialect. The transformation replaces CAL state definitions with `memref.alloc`
    operations, and rewrites `cal.get` and `cal.set` into `memref.load` and
    `memref.store`, respectively.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];
  let constructor = "mlir::cal::lowerCalStateToMemref()";
  let dependentDialects = [
    "cal::CalDialect",
    "index::IndexDialect",
    "arith::ArithDialect",
    "memref::MemRefDialect"
  ];
}

def HoistCalStateOutOfActor: Pass<"hoist-cal-state-out-of-actor"> {
  let summary = "Move all actor initialisation variables out of cal.actors and into cal.network operation that create instances of that actor..";
  let description = [{
    In the CAL dialect, each `cal.actor` may declare state variables or constant values in its
    entry block that are only needed to initialize the actor's internal state before its
    `cal.execution_body` runs. These initialization-only operations (for example,
    `cal.create_state_var`, `arith.constant`, or `cal.set`) cannot be directly passed into a
    function-like call and must be hoisted to the call site.

    The `hoist-cal-state-out-of-actor` pass traverses each `cal.actor` definition and:
      1. Converts every result of an entry-block initialization operation into a
         new block argument of the actor.
      2. Replaces all uses of those init-ops with the new arguments.
      3. Deletes the original initialization operations from the actor body.
    As a result, the actor's body becomes purely the `cal.execution_body`, whose dynamic
    behavior can be lowered to a function taking explicit state parameters.

    Simultaneously, at each invocation site in a `cal.network` (via `cal.create_instance`),
    those former initialization values are materialized (by cloning the same init-ops immediately
    above the `create_instance`) and passed in as operands. This two-phase transformation
    cleanly separates “static” actor state setup from the “dynamic” execution logic.

    After this pass, you can treat each actor's execution region as a standalone function
    with explicit parameters for its state. We can then lower these CAL actors into callable
    functions.

    NOTE: This pass needs to have the --canonicalize pass run before it or it can
    result in errors.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];
  let constructor = "mlir::cal::hoistCalStateOutOfActor()";
}

#endif // CAL_PASS
