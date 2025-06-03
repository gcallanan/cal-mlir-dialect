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

def HoistCalStateOutOfActor: Pass<"hoist-cal-state-out-of-actor"> {
  let summary = "Move all actor initialisation variables out of cal.actors and into cal.network operation that create instances of that actor.";
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

def InsertCalPortPredicates: Pass<"insert-cal-port-predicates"> {
  let summary = "Insert predicates/guards for FIFO port accesses in cal.actions";
  let description = [{
    This pass inserts `cal.predicate` operations into `cal.action` bodies to guard
    FIFO port accesses. These predicates ensure that the
    conditions for safely executing FIFO operations (like availability of input
    tokens or sufficient output buffer space) are met before the action executes.

    Each `fifo.pop` or `fifo.push` inside an action corresponds to an input (consumption)
    or output (production) port that may require a runtime guard. This pass performs
    static analysis to determine the expected number of tokens
    required or produced at each port per action. For each such port, a corresponding
    `cal.predicate` is inserted at the start of the action.

    For each consumption port:
      - The predicate uses `fifo.size` to get the current token count.
      - It compares this to the required rate as produced from the static analysis.

    For each production port:
      - The predicate uses `fifo.space` to get the available buffer space.
      - It performs the same comparison as above.

    Example Input:
      cal.action {
        %token = fifo.pop(%in1: !fifo.output_port<i32>) : i32
        fifo.push(%out0: !fifo.input_port<i32>, %token: i32)
      }

    Example Output:
      cal.action {
        cal.predicate {
          %1 = fifo.size(%arg1 : !fifo.output_port<i32>) : index
          %2 = arith.index_cast %1 : index to i32
          %3 = arith.cmpi sge, %2, %c1_i32 : i32
          cal.predicate_result %3 : i1
        }
        cal.predicate {
          %1 = fifo.space(%arg2 : !fifo.input_port<i32>) : index
          %2 = arith.index_cast %1 : index to i32
          %3 = arith.cmpi sge, %2, %c1_i32 : i32
          cal.predicate_result %3 : i1
        }
        %0 = fifo.pop(%arg1 : !fifo.output_port<i32>) : i32
        fifo.push(%arg2 : !fifo.input_port<i32>, %0 : i32)
      }

    Sometimes, actions are written without guards on the ports but it is
    nice to have them when generating an executable actor. This pass takes
    care of that by inserting the necessary guards on the different ports
    in the action body. This lets the actions be executed safely even if they
    were not written with the guards explicitly stated.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];
  let constructor = "mlir::cal::insertCalPortPredicates()";
  let dependentDialects = [
    "cal::CalDialect",
    "fifo::FifoDialect",
    "arith::ArithDialect"
  ];
}

def ConvertCalActionsToExecutionBodies: Pass<"convert-cal-actions-to-execution-bodies"> {
  let summary = "Lower cal.action operations to a unified cal.execution_body operation inside each cal.actor";
  let description = [{
    This pass transforms `cal.actor` operations by lowering all contained
    cal.action operations into a single cal.execution_bod`. The resulting
    structure uses explicit control flow to sequence and guard each action's
    execution, making it easier to lower actors into imperative backends.

    For each `cal.action`, the pass:
      - Extracts its `cal.predicate` operations and evaluates them in the
        `cal.execution_body` block.
      - Combines all predicate results using equality checks.
      - Associates the result with the action as its firing condition.

    Actions are sorted by their optional `priority` attribute (defaulting to 0),
    and are then wrapped in nested `scf.if` regions that preserve this priority:
    higher-priority actions are evaluated first, and only the first enabled
    action executes during a given invocation of the actor.

    After all actions are transformed:
      - A single `cal.action_done` op is added to indicate whether any action
        was executed.
      - The original `cal.action` operations are erased.

    Example Input:
      cal.actor @sink() {
        cal.action {
          cal.predicate {
            %1 = fifo.size(%arg0) : index
            %2 = arith.index_cast %1 : i32
            %3 = arith.cmpi sge, %2, %c1_i32 : i32
            cal.predicate_result %3 : i1
          }
          %0 = fifo.pop(%arg0)
          fifo.print("token = %d", %0)
        }
      }

    Example Output:
      cal.actor @sink() {
        cal.execution_body {
          %0 = fifo.size(%arg0) : index
          %1 = arith.index_cast %0 : i32
          %2 = arith.cmpi sge, %1, %c1_i32 : i32
          %3 = scf.if %2 -> (i1) {
            %4 = fifo.pop(%arg0)
            fifo.print("token = %d", %4)
            scf.yield %true : i1
          } else {
            scf.yield %false : i1
          }
          cal.action_done %3 : i1
        }
      }

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];
  let constructor = "mlir::cal::convertCalActionsToExecutionBodies()";
  let dependentDialects = [
    "cal::CalDialect",
    "fifo::FifoDialect",
    "arith::ArithDialect",
    "scf::SCFDialect"
  ];
}

#endif // CAL_PASS
