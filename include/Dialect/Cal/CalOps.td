//===- CalOps.td - Cal dialect ops -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef CAL_OPS
#define CAL_OPS

include "Dialect/Cal/CalTypes.td"
include "Dialect/Fifo/FifoTypes.td"
include "mlir/IR/OpBase.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/SymbolInterfaces.td"
include "mlir/IR/CommonAttrConstraints.td"

// This operation is declared with the folloing interfaces:
//    - [Symbol]: This actor needs to have a name and this name needs to be part
//                of the symbol table so that it can be accessed from other
//                locations.
//    - [NoTerminator]: A terminator operation is signifies the end of a control
//                      flow region. This does not make sense for an actor
//                      operation as there is no single controle flow defined
//                      yet. When we transform it for execution, then we will
//                      need to decide how action regions are connected.
//    - [IsolatedFromAbove]: The actor does not have side effects or dependences
//                           on the operations above or around it, so it can
//                           be marked as isolated.
def Cal_ActorOp : Cal_Op<"actor", [Symbol, IsolatedFromAbove, NoTerminator]> {
  let summary = "CAL actor operation";
  let description = [{
    The `cal.actor` operation defines a computational actor in a CAL-based
    dataflow model. An actor encapsulates both persistent state and executable
    behavior, and communicates with its environment via typed FIFO ports.

    Each actor contains a body region that must include either:
    - One or more `cal.action` operations, each representing an isolated control
      flow graph (CFG) with optional guards, internal computations, and FIFO
      interactions; or
    - A single `cal.execution_body` operation, which represents the entire actor’s
      behavior as one combined CFG. This unified body is typically the result of
      composing multiple `cal.action`s during lowering or optimization.

    Actors can optionally declare input and output ports using `ports_in` and
    `ports_out`. These ports describe how the actor connects to FIFO channels when
    instantiated in a `cal.network`.

    Example:
      cal.actor @my_actor(%inc: i32)
        ports_in(%in0: !fifo.output_port<i32>)
        ports_out(%out0: !fifo.input_port<i32>)
      {
        %s1 = cal.create_state_var<i32> : !cal.state_ref<i32>
        cal.set(%s1: !cal.state_ref<i32>, %inc: i32)

        cal.action {
          %0 = cal.get(%s1: !cal.state_ref<i32>) : i32
          %1 = arith.addi %0, %inc : i32
          cal.set(%s1: !cal.state_ref<i32>, %1: i32)
          fifo.push(%out0: !fifo.input_port<i32>, %0: i32)
        }
      }

    In the example above, the actor defines a state variable and a single action that
    increments the state and pushes the old value to an output FIFO port.

    ## Semantics

    - `cal.action` blocks allow for fine-grained specification of behavior and may be
      independently guarded using `cal.predicate` operations.
    - During compilation or transformation, actions may be merged into a single
      `cal.execution_body`, forming a complete CFG for the actor's runtime behavior.
    - The actor's body must contain *either* a set of `cal.action`s *or* a single
      `cal.execution_body`, but not both.

    This design enables both modular authoring of actions and efficient downstream
    scheduling or transformation into a unified control structure.

    This operation has the following traits:
    - [Symbol]: This actor needs to have a name and this name needs to be part
                of the symbol table so that it can be accessed from other
                locations.
    - [NoTerminator]: A terminator operation is signifies the end of a control
                      flow region. This does not make sense for an actor
                      operation as there is no single controle flow defined
                      yet. When we transform it for execution, then we will
                      need to decide how action regions are connected.
    - [IsolatedFromAbove]: The actor does not have side effects or dependences
                           on the operations above or around it, so it can
                           be marked as isolated.
  }];

  let arguments = (ins
    SymbolNameAttr:$sym_name // Actor Name: Required by the Symbol interface
  );

  let regions = (region AnyRegion:$body);

  //let assemblyFormat = "$sym_name  `(` $input_port `)`  ( $body^ )? attr-dict ";
  let hasCustomAssemblyFormat = 1;

  let extraClassDeclaration = [{
    // Get the number of input ports declared in the actor.
    int inDegree();

    // Get the number of output ports declared in the actor.
    int outDegree();

    // Determine if the actor is a simple actor, meaning it has only one action
    // and no predicates and a single input and output port.
    bool isSimpleActor();
  }];
}


def Cal_NetworkOp : Cal_Op<"network", [Symbol, NoTerminator, IsolatedFromAbove]> {
  let summary = "Symbolic CAL network operation (hierarchical composition)";
  let description = [{
    The `cal.network` operation defines a (now symbolic) network that
    instantiates actors (and in future: other networks) and the connections
    between them. A network can expose parameters as well as typed FIFO input
    and output ports, similar to a `cal.actor`, enabling hierarchical
    composition.

    Syntax (new symbolic form):
      cal.network @name(%p0: i32, %p1: f32)
          ports_in(%a: !fifo.output_port<i32>)
          ports_out(%b: !fifo.input_port<i32>) {
        ... body ...
      }

    The region entry block arguments are, in order:
      1. All standard (non-port) parameters
      2. All `ports_in` FIFO output port arguments
      3. All `ports_out` FIFO input port arguments

    Backwards compatibility: the previous anonymous form `cal.network { ... }`
    is being replaced by the symbolic form and should be migrated. (A legacy
    parser path can be added if needed; current implementation requires a
    symbol name.)
  }];

  let arguments = (ins
    SymbolNameAttr:$sym_name // Network symbol name
  );

  let regions = (region AnyRegion:$body);

  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;

  let extraClassDeclaration = [{
    int inDegree();
    int outDegree();
  }];
}

def Cal_CreateInstanceOp : Cal_Op<"create_instance", [DeclareOpInterfaceMethods<SymbolUserOpInterface>,HasParent<"NetworkOp">]> {
  let summary = "Creates an instance of a CAL actor";
  let description = [{
    The `cal.create_instance` operation instantiates a CAL actor, creating a new
    instance of the specified actor definition. This operation allows multiple
    instances of the same actor to exist in a system.

    Example:
      cal.create_instance @merge "merge" (%c0: i32)
        ports_in (%outputPort, %outputPort_2 : !fifo.output_port<i32>, !fifo.output_port<i32>)
        ports_out (%inputPort_3 : !fifo.input_port<i32>)

    This creates an instance of the `@merge` actor with the name `"merge"`, and
    connects its input and output ports to the specified FIFO ports. ports_in
    and ports_out are optional.

    It is required (and verified by the passer) that the standard argument
    operands and the operands in ports_out and ports_in match what is specified
    in the corresponding actor definition (in this case @merge).

    The instance name ("merge" in this case) is optional.
  }];

  let arguments = (ins
    FlatSymbolRefAttr:$actorRef, // Reference to the actor definition
    OptionalAttr<StrAttr>:$instanceName, // Optional name for the instance
    Variadic<AnyType>:$operands // The operands to be passed to the actor instance
  );

  let extraClassDeclaration = [{
    // Get the actor definition this instance is based on.
    cal::ActorOp getActor();
  }];

  let hasCustomAssemblyFormat = 1;
}

// TODO Explain, make sure action_done is a cumpulsory terminator
def Cal_ExecutionBody : Cal_Op<"execution_body", [HasParent<"ActorOp">, AutomaticAllocationScope]> {
  let summary = "Execution body of a CAL actor";
  let description = [{
    Represents the combined execution region of a CAL actor.

    This region contains the merged control flow of all individual actions within
    the actor, representing the complete behavior of the actor during execution.

    Unlike individual `cal.action` regions which encapsulate single actions, the
    execution body integrates all these actions into a single, unified control flow
    graph.

    This operation serves as a container for the actor's executable logic after
    action merging and scheduling.

    The region must be terminated by a `cal.action_done` operation indicating the
    completion of execution. It returns a boolean indicating whether
    the action was successfully executed or not. This is used to signal whether
    an action executed or not, which helps with scheduling.

    Typically generated by compiler passes that lower or optimize CAL actors for
    execution.

    Example usage:
    cal.actor @sink()
        ports_in(%in0: !fifo.output_port<i32>)
    {
        cal.execution_body
        {
            // Condition : Ensure that we have a token to consume
            %num_tokens_available = fifo.size(%in0: !fifo.output_port<i32>) : index
            %zero = arith.constant 0 : index
            %token_available = arith.cmpi sgt, %num_tokens_available, %zero : index

            // If a token is available, pop it and print
            scf.if %token_available {
                // Perform the action: Retrieve and print the token
                %token = fifo.pop(%in0: !fifo.output_port<i32>) : i32
                fifo.print("Popped Token: %d\0A\00", %token) : (i32)
                scf.yield
            } else {
                %false = arith.constant 0 : i1
                scf.yield
            }
            cal.action_done %token_available : i1
        }
    }

  }];

  let regions = (region AnyRegion:$body);

  let assemblyFormat = "$body attr-dict ";
}

def CAL_ActionDoneOp : Cal_Op<"action_done", [Terminator, HasParent<"ExecutionBody">]> {
  let summary = "Indicates the completion of a CAL action's execution";

  let description = [{
    The `cal.action_done` operation marks the termination point of an execution
    region within a CAL actor or execution body.

    It signals that the action or execution body has completed its execution,
    optionally conveying whether the action was executed via the `has_executed`
    boolean attribute.

    This terminator is required to properly delineate the end of an action's
    control flow region.

    It is used by compiler passes and runtime systems to determine action
    completion status and to coordinate scheduling or further execution steps.

    Example:

  cal.action_done true : i1

  }];

  let arguments = (ins I1:$has_executed);

  let assemblyFormat = "attr-dict $has_executed `:` type($has_executed)";
}

// TODO Explain purpose of has parent and NoTerminator
def Cal_ActionOp : Cal_Op<"action", [HasParent<"ActorOp">, NoTerminator, AutomaticAllocationScope]> {
  let summary = "Defines a single atomic unit of behavior within a CAL actor";
  let description = [{
    The `cal.action` operation defines a single atomic behavioral unit within a
    `cal.actor`. Each action represents its own self-contained control flow graph
    (CFG) and is a candidate for execution based on its internal conditions,
    including predicate evaluation and data availability.

    An actor may contain multiple `cal.action` operations, each describing an
    independent sequence of behavior. Alternatively, during lowering, these
    multiple actions may be composed into a single unified control structure
    through a `cal.execution_body` region, which merges the individual CFGs.

    ## Structure and Semantics

    - Each action consists of an optional name and an optional priority attribute.
      Priorities are used to resolve which action to fire when multiple are
      simultaneously enabled.
    - The body of a `cal.action` is a region that may contain (among other operations):
      - `cal.predicate` blocks: Used to guard action execution.
      - FIFO operations such as `fifo.pull` and `fifo.push`.
      - State operations such as `cal.get` and `cal.set`.
    - The operations must follow a valid sequence:
      `cal.predicate` → `fifo.pull` → `cal.set` → `fifo.push`.
      This ordering is verified to ensure deterministic behavior.
    - The NoTerminator trait is here as nothing needs to be returned when an
      action finished executing.

    ## Example

    cal.action {
      cal.predicate {
        %true = arith.constant 1 : i1
        cal.predicate_result %true : i1
      }
      %v = cal.get(%state: !cal.state_ref<i32>) : i32
      %inc = arith.addi %v, %c1 : i32
      cal.set(%state: !cal.state_ref<i32>, %inc: i32)
      fifo.push(%out: !fifo.input_port<i32>, %v: i32)
    }
  }];

  let arguments = (ins
    OptionalAttr<StrAttr>:$actionName, // Optional name for the action
    OptionalAttr<I32Attr>:$priority // Optional priority for the action
  );

  let regions = (region AnyRegion:$body);

  let extraClassDeclaration = [{
    llvm::MapVector<mlir::Value, int> getPortRates();
  }];

  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}


def Cal_Predicate : Cal_Op<"predicate", [HasParent<"ActionOp">]> {
  let summary = "Predicate region for conditional action execution";
  let description = [{
    The `cal.predicate` operation defines a region within a `cal.action` that computes
    a condition controlling whether the action is eligible to fire. This region contains
    a sequence of operations and must terminate with a `cal.predicate_result` operation,
    which returns a single boolean (`i1`) indicating the result of the predicate evaluation.

    The `cal.predicate` must appear at the beginning of a `cal.action` body, before any
    `fifo.pull`, `cal.set`, or `fifo.push` operations. Multiple predicate blocks can be
    declared within a single action, allowing for more complex eligibility conditions.

    This region may contain operations that compute the predicate result, but it is
    subject to strict restrictions enforced by the verifier:
    - No FIFO push or pop operations are allowed inside the predicate region.
    - State variables cannot be modified within this region.

    Example:
      cal.predicate {
        %true = arith.constant 1 : i1
        cal.predicate_result %true : i1
      }

    The value passed to `cal.predicate_result` determines whether this predicate is
    satisfied. The final eligibility for the action may be based on the combination
    of multiple predicate regions, depending on execution semantics.
  }];

  let regions = (region AnyRegion:$body);

  let assemblyFormat = "$body attr-dict ";
}

// TODO Explain
def CAL_PredicateResultOp : Cal_Op<"predicate_result", [Terminator, HasParent<"Predicate">]> {
  let summary = "Result of a predicate evaluation";
  let description = [{
    The `cal.predicate_result` operation serves as the terminator of a `cal.predicate`
    region. It returns a single boolean (`i1`) value representing the outcome of the
    predicate evaluation within the action.

    This value indicates whether the predicate condition was met (true) or not (false),
    determining if the associated action is eligible for execution.

    The `cal.predicate_result` must be the last operation in the `cal.predicate` region
    and must return exactly one boolean result.

    Example:
      cal.predicate_result %cond : i1
  }];

  let arguments = (ins I1:$evaluation_result);

  let assemblyFormat = "attr-dict $evaluation_result `:` type($evaluation_result)";
}

def CAL_CreateStateVarOp : Cal_Op<"create_state_var", [MemoryEffects<[MemAlloc]>, MemoryEffects<[MemWrite]>]> {
  let summary = "Creates a state variable";
  let description = [{
    The `cal.create_state_var` operation creates a state variable
    of a specified type within the `cal` dialect and returns a reference to it.
    This reference can then be used by other operations to read from or write to
    the state.

    This operation is intended for defining state variables that persist
    across firings of the actor.

    Note that `create_state_var` only allocates the variable; it does not
    initialize it with a specific value. The initial contents are undefined
    unless explicitly initialized by a subsequent operation.

    Arguments:
    - `stateType`: A type attribute specifying the element type of the state
      variable to be created.

    Results:
    - `stateVarRef`: A reference to the allocated state variable, of
      type `!cal.state_ref<T>`, where `T` matches the given `stateType`.

    Example:
      %ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
    This allocates a new state variable of type `i32` and returns a reference to
    it that can be used by future state operations.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];

  let arguments = (ins
    TypeAttr:$stateType // The type of the state variable
  );

  let results = (outs
    AnyType:$stateVarRef  // The reference to the created state variable
  );

  let assemblyFormat = "`<` $stateType `>` attr-dict `:` type($stateVarRef)";

  let hasVerifier = 1; // Enables verification logic in C++.
}

def CAL_StateGetOp : Cal_Op<"get", [MemoryEffects<[MemRead]>]> {
  let summary = "Get the value stored in a state variable reference";
  let description = [{
    The `cal.get` operation reads the current value stored in a state variable
    referenced by a `!cal.state_ref<T>`. It produces a value of type `T` that
    reflects the latest state written to the variable, whether from an
    initialization or a previous `cal.set` operation.

    This operation models a pure read from a persistent memory location and is
    side-effect-free aside from its dependency on the current program state. It
    is expected to be used in computations that require the stored value without
    modifying it.

    Arguments:
    - `stateRef`: A reference to the state variable to read from. This must be of
      type `!cal.state_ref<T>`, where `T` is the type of the stored value.

    Results:
    - `stateValue`: The value retrieved from the referenced state variable, of
      type `T`.

    Example:
      %ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
      %val1 = cal.get(%ref0: !cal.state_ref<i32>) : i32
    This retrieves the `i32` value currently stored in the state variable
    referenced by `%ref0`.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];

  let arguments = (ins
    AnyType:$stateRef // The reference to the state variable
  );

  let results = (outs
    AnyType:$stateValue   // The value retrieved from the state variable
  );

  let assemblyFormat = "`(` $stateRef `:` type($stateRef) `)` attr-dict `:` type($stateValue)";

  let hasVerifier = 1; // Enables verification logic in C++.
}

def CAL_StateSetOp : Cal_Op<"set", [MemoryEffects<[MemWrite]>]> {
  let summary = "Set the value stored in a state variable reference";
  let description = [{
    The `cal.set` operation updates the value stored in a state variable
    referenced by a `!cal.state_ref<T>`. It writes a new value into the state
    variable, overwriting any previously stored value.

    This operation models a side-effecting store to a persistent memory location
    represented by the `stateRef`. The value must be of the same type as the
    state variable's declared element type to ensure type safety and consistency
    in subsequent reads or operations.

    This operation does not return any results, as its primary effect is the
    mutation of program state.

    Arguments:
    - `stateValue`: The value to be written into the state variable.
    - `stateRef`: A reference to the state variable being updated. This should
      be of type `!cal.state_ref<T>` where `T` matches the type of `stateValue`.

    Example:
      %ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
      %c1 = arith.constant 1 : i32
      cal.set(%ref0: !cal.state_ref<i32>, %c0: i32)
    This writes the value `%c0` into the state variable referenced by `%ref0`.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];

  let arguments = (ins
    AnyType:$stateValue, // The value to be set in the state variable
    AnyType:$stateRef // The reference to the state variable
  );

  let assemblyFormat = "`(` $stateRef `:` type($stateRef) `,` $stateValue `:` type($stateValue)  `)` attr-dict";

  let hasVerifier = 1; // Enables verification logic in C++.
}

#endif // CAL_OPS
