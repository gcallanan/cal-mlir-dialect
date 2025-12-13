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

def LowerCalFsmToExecutionBody: Pass<"lower-cal-fsm-to-execution-body"> {
  let summary = "Lower cal.fsm schedules to a single cal.execution_body inside each cal.actor";
  let description = [{
    This pass lowers the explicit scheduling expressed via `cal.fsm` (states and
    `cal.transition`s) into an executable `cal.execution_body` region. For the
    current state, it selects among transitions by the referenced action's
    priority (ties broken by transition order), checks the action's predicates,
    executes at most one action, updates the state, and yields an `i1` that
    signals whether any action fired. After lowering, the actor contains no
    `cal.action` or `cal.fsm`.

    Note: Action guards remain in the actions via `cal.predicate`. Transition
    edges do not carry their own guards.
  }];
  let constructor = "mlir::cal::lowerCalFsmToExecutionBody()";
  let options = [
    Option<"requirePushSpace", "require-push-space", "bool", /*default=*/"true",
           "When true, add fifo.space(port) >= pushes checks for actions that push to input ports. "
           "If false, only pop readiness (fifo.size >= pops) is enforced.">
  ];
  let dependentDialects = [
    "cal::CalDialect",
    "fifo::FifoDialect",
    "arith::ArithDialect",
    "scf::SCFDialect"
  ];
}

def InferCalDynamicStateShapes: Pass<"infer-cal-dynamic-state-shapes"> {
  let summary = "Infer and specialize dynamic memref state variable shapes when statically known";
  let description = [{
    This pass performs a lightweight shape inference over CAL actor state variables
    defined via `cal.create_state_var` whose element type is a `memref` with one
    or more dynamic dimensions (currently implemented for rank-1 forms like
    `memref<?xT>`). When it can prove a fixed extent, it rewrites the state
    variable type and the corresponding `memref.alloc` to a static sized memref.

    Inference strategy (initial implementation):
      * Find `cal.create_state_var<memref<?xT>>` with exactly one `cal.set` that
        stores the result of a `memref.alloc(%sz)` of matching type.
      * Trace `%sz` through trivial casts (`arith.index_cast`, `arith.sitofp`/`fptosi`
        are ignored for integer/index forms) to an `arith.constant` integer / index.
      * If the value is a compile-time constant, replace:
           - the state var type `memref<?xT>` -> `memref<NxT>`
           - the alloc result type similarly, dropping the dynamic operand (canonical).
      * All uses of the old alloc and state var are updated automatically.

    This specialization improves later bufferization and eliminates verifier
    errors caused by hoisting dynamic allocs without their size operands.
    Remaining truly dynamic cases are left unchanged for runtime handling.

    Future extensions will handle multi-rank memrefs, loop-derived trip counts,
    and parameter-based symbolic extents.
  }];
  let constructor = "mlir::cal::inferCalDynamicStateShapes()";
  let dependentDialects = [
    "cal::CalDialect",
    "memref::MemRefDialect",
    "arith::ArithDialect"
  ];
}
// Removed: MergeSimpleCalActors pass (replaced by static scheduling approach)

def DetectRecursiveTypes: Pass<"cal-detect-recursive-types"> {
  let summary = "Detect and mark recursive algebraic types";
  let description = [{
    This pass analyzes `!cal.variant` and `!cal.product` types to detect
    recursive type structures. A type is considered recursive if it directly
    or transitively contains a reference to itself in any of its fields.

    Examples of recursive types:
    - List: `!cal.variant<"List", [("Cons", [i32, !cal.variant<"List", ...>]), ("Nil", [])]>`
    - Tree: `!cal.variant<"Tree", [("Node", [i32, !cal.variant<"Tree">, !cal.variant<"Tree">]), ("Leaf", [i32])]>`
    - Mutual recursion: Type A contains Type B which contains Type A

    The pass performs the following:
    1. Collects all `!cal.variant` and `!cal.product` types used in the module
    2. Builds a type dependency graph
    3. Detects cycles using Tarjan's strongly connected components algorithm
    4. Marks operations that create or use recursive types with attributes

    The analysis results are used by subsequent passes (`cal-insert-arenas`,
    `cal-insert-rc-for-state`) to determine which types need boxing/heap
    allocation versus inline storage.

    Output attributes added to operations:
    - `cal.recursive_type` on `cal.variant.create` for recursive types
    - `cal.recursive_fields = [indices...]` marking which variant fields are recursive

    Example transformation:
      Input:
        %list = cal.variant.create "Cons"(%head, %tail)
                : !cal.variant<"List", ...>

      Output:
        %list = cal.variant.create "Cons"(%head, %tail) {cal.recursive_type}
                : !cal.variant<"List", ...>
  }];
  let constructor = "mlir::cal::detectRecursiveTypes()";
  let dependentDialects = [
    "cal::CalDialect"
  ];
}

def InsertArenas: Pass<"cal-insert-arenas"> {
  let summary = "Insert arena allocation/deallocation for action-scoped memory";
  let description = [{
    This pass inserts arena creation and destruction operations around action
    bodies to manage memory for recursive algebraic types. The pass transforms
    actions marked with recursive type usage (from `cal-detect-recursive-types`)
    by:

    1. Creating an arena at the start of each `cal.execution_body`
    2. Destroying the arena before `cal.action_done`
    3. Wrapping variant/product creation ops that use recursive types to
       allocate from the arena
    4. Inserting `cal.token.wrap` before `fifo.push` and `cal.token.unwrap`
       after `fifo.pop` for recursive types crossing FIFO boundaries

    The arena provides efficient bump-pointer allocation for temporary values
    within an action. All allocations are freed together when the action
    completes, avoiding individual deallocation overhead.

    Example transformation:
      Input:
        cal.execution_body {
          %list = cal.variant.create "Cons"(%head, %tail) {cal.recursive_type}
                  : !cal.variant<"List", ...>
          fifo.push(%out, %list) {cal.recursive_token}
          cal.action_done %true : i1
        }

      Output:
        cal.execution_body {
          %arena = cal.arena.create : !cal.arena
          %list = cal.variant.create "Cons"(%head, %tail) in %arena
                  : !cal.variant<"List", ...>
          %token = cal.token.wrap %list from %arena
                   : !cal.variant<"List", ...> -> !cal.token<!cal.variant<"List", ...>>
          fifo.push(%out, %token)
          cal.arena.destroy %arena : !cal.arena
          cal.action_done %true : i1
        }

    Prerequisites:
    - Run `cal-detect-recursive-types` first to mark recursive operations
    - Run after `convert-cal-actions-to-execution-bodies`
  }];
  let constructor = "mlir::cal::insertArenas()";
  let dependentDialects = [
    "cal::CalDialect",
    "fifo::FifoDialect"
  ];
}

def InsertRCForState: Pass<"cal-insert-rc-for-state"> {
  let summary = "Insert reference counting for state variables with recursive types";
  let description = [{
    This pass transforms state variable operations (`cal.create_state_var`,
    `cal.get`, `cal.set`) to use reference counting when the state contains
    recursive algebraic types. Reference counting ensures proper memory
    management for values that persist across action firings.

    The pass performs the following transformations:

    1. For `cal.create_state_var` of a recursive type:
       - Wraps the state type in `!cal.rc<T>` at the conceptual level
       - The actual storage remains a state_ref, but operations are modified
       - Marks the state variable with `cal.rc_managed` attribute

    2. For `cal.set` operations on RC-managed state:
       - Insert `cal.rc.release` on the old value before storing
       - Insert `cal.rc.retain` on the new value (or `cal.rc.alloc` if from arena)
       - Marks the operation with `cal.rc_updated` attribute

    3. For `cal.get` operations on RC-managed state:
       - The returned value is a borrow (no retain needed for read-only use)
       - If the value escapes (e.g., stored elsewhere), retain is needed
       - Marks with `cal.rc_borrowed` attribute

    Example transformation:
      Input:
        %state = cal.create_state_var<T> {cal.recursive_type} : !cal.state_ref<T>
        %old = cal.get(%state: !cal.state_ref<T>) : T
        cal.set(%state: !cal.state_ref<T>, %new: T)

      Output:
        %state = cal.create_state_var<T> {cal.rc_managed} : !cal.state_ref<T>
        %old = cal.get(%state: !cal.state_ref<T>) {cal.rc_borrowed} : T
        cal.rc.release %old_prev : T  // release previous value
        %retained = cal.rc.retain %new : T  // retain new value (if from another RC)
        // or: %retained = cal.rc.alloc %new : T -> !cal.rc<T>  // alloc if from arena
        cal.set(%state: !cal.state_ref<T>, %retained: T) {cal.rc_updated}

    The pass uses dataflow analysis to determine if values need retain on get
    (escape analysis) and whether the new value in set comes from an arena
    (needs alloc) or another RC container (needs retain).

    Prerequisites:
    - Run `cal-detect-recursive-types` first to mark recursive types
    - Run `cal-insert-arenas` first if arena allocation is used
  }];
  let constructor = "mlir::cal::insertRCForState()";
  let dependentDialects = [
    "cal::CalDialect"
  ];
}

def MaterializeRCOps: Pass<"cal-materialize-rc-ops"> {
  let summary = "Materialize RC operations from attributes set by insert-rc-for-state";
  let description = [{
    This pass transforms state variable operations that are marked with RC
    attributes (by `cal-insert-rc-for-state`) into actual `cal.rc.*` operations.
    
    The pass converts the following patterns:
    
    1. `cal.set` with `cal.rc_release_old`:
       - Insert `cal.get` to load the old RC value
       - Insert `cal.rc.release` on the old value
       
    2. `cal.set` with `cal.rc_needs_alloc`:
       - New value comes from arena-allocated memory
       - Insert `cal.rc.alloc` to deep-copy into RC container
       
    3. `cal.set` with `cal.rc_needs_retain`:
       - New value is borrowed from another RC
       - Insert `cal.rc.retain` to increment reference count
       
    4. `cal.get` with `cal.rc_borrowed`:
       - Currently no transformation (borrow is zero-cost)
       - Future: escape analysis may require retain
    
    Example transformation:
      Input:
        cal.set(%state: !cal.state_ref<T>, %new: T) {cal.rc_release_old, cal.rc_needs_alloc}
      
      Output:
        %old = cal.get(%state: !cal.state_ref<!cal.rc<T>>) : !cal.rc<T>
        cal.rc.release %old : !cal.rc<T>
        %rc_new = cal.rc.alloc %new : T -> !cal.rc<T>
        cal.set(%state: !cal.state_ref<!cal.rc<T>>, %rc_new: !cal.rc<T>)
    
    This pass must run:
    - AFTER `cal-detect-recursive-types` (marks recursive types)
    - AFTER `cal-insert-rc-for-state` (marks state ops with RC attributes)
    - BEFORE `lower-cal-state-to-memref` (which would lose RC semantics)
  }];
  let constructor = "mlir::cal::materializeRCOps()";
  let dependentDialects = [
    "cal::CalDialect"
  ];
}

#endif // CAL_PASS
