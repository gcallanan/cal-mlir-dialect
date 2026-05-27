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
include "mlir/Interfaces/ControlFlowInterfaces.td"
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
    SymbolNameAttr:$sym_name, // Actor Name: Required by the Symbol interface
    OptionalAttr<ArrayAttr>:$inPortNames,  // Optional symbolic names for ports_in (size must equal inDegree)
    OptionalAttr<ArrayAttr>:$outPortNames, // Optional symbolic names for ports_out (size must equal outDegree)
    OptionalAttr<UnitAttr>:$nonPreemptive  // Optional marker: when present, scheduler should drain this actor (non-preemptive)
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
  let hasVerifier = 1;
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
    SymbolNameAttr:$sym_name,                 // Network symbol name
    OptionalAttr<ArrayAttr>:$inPortNames,     // Optional symbolic names for ports_in (size must equal inDegree)
    OptionalAttr<ArrayAttr>:$outPortNames     // Optional symbolic names for ports_out (size must equal outDegree)
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
      cal.create_instance @merge "merge" device_affinity="cpu0" (%c0: i32)
        ports_in (%outputPort, %outputPort_2 : !fifo.output_port<i32>, !fifo.output_port<i32>)
        ports_out (%inputPort_3 : !fifo.input_port<i32>)

    This creates an instance of the `@merge` actor with the name `"merge"`, sets
    its CPU affinity to "cpu0", and connects its input and output ports to the
    specified FIFO ports. ports_in, ports_out, and cpu_affinity are optional.

    The device_affinity attribute allows specifying a device or core affinity hint
    for the actor instance (e.g., "cpu0", "core1"). This can be used by runtime
    systems or schedulers to bind the actor to specific hardware resources.

    It is required (and verified by the passer) that the standard argument
    operands and the operands in ports_out and ports_in match what is specified
    in the corresponding actor definition (in this case @merge).

    The instance name ("merge" in this case) is optional.
  }];

  let arguments = (ins
    FlatSymbolRefAttr:$actorRef, // Reference to the actor definition
    OptionalAttr<StrAttr>:$instanceName, // Optional name for the instance
    OptionalAttr<StrAttr>:$deviceAffinity, // Optional device affinity (e.g. "cpu0", "core1")
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
    - `sizes` (optional): A variadic list of `index`-typed SSA operands that
      provide dynamic dimension sizes when the state type is a `memref` or
      `tensor` with dynamic dimensions. One operand is required per dynamic
      dimension, in order.
    - `stateType`: A type attribute specifying the element type of the state
      variable to be created. Supported element types are scalars, tensors and
      memrefs. For memrefs/tensors with dynamic dimensions, provide matching
      `sizes` operands.

    Results:
    - `stateVarRef`: A reference to the allocated state variable, of
      type `!cal.state_ref<T>`, where `T` matches the given `stateType`.

    Examples:
      %ref0 = cal.create_state_var<i32> : !cal.state_ref<i32>
      %ref1 = cal.create_state_var<memref<?x4xf32>>(%h : index)
              : !cal.state_ref<memref<?x4xf32>>
    This allocates a new state variable of type `i32` and returns a reference to
    it that can be used by future state operations.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];

  let arguments = (ins
    Variadic<Index>:$sizes,  // Optional dynamic dimension sizes (in order)
    TypeAttr:$stateType      // The type of the state variable
  );

  let results = (outs
    AnyType:$stateVarRef  // The reference to the created state variable
  );

  let assemblyFormat = "`<` $stateType `>` (`(` $sizes `:` type($sizes)^ `)`) ? attr-dict `:` type($stateVarRef)";

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

//===----------------------------------------------------------------------===//
// High-level symbolic network construction ops (Step 1)
// These ops are intentionally lightweight and are expected to be erased by an
// elaboration pass that lowers them into fifo.create + cal.create_instance.
//===----------------------------------------------------------------------===//

// cal.instantiate
// Creates a symbolic instance handle for an actor. Actual ports are not
// connected here; connections are established separately via connect ops.
// Syntax example:
//   %h = cal.instantiate @MyActor ( %p0, %p1 : i32, f32 ) instance("optName")
// or (no params / no name):
//   %h = cal.instantiate @MyActor
// The result is !cal.instance<@MyActor>.
def Cal_InstantiateOp : Cal_Op<"instantiate", [Pure]> {
  let summary = "Create a symbolic actor instance handle";
  let description = [{
    Produces a `!cal.instance<@Actor>` handle for use in subsequent structural
    connection operations. This does not allocate FIFOs nor materialize a
    `cal.create_instance` op; that is deferred to a later elaboration pass.
  }];
  let arguments = (ins
    FlatSymbolRefAttr:$actorRef,                  // Target actor symbol
    OptionalAttr<StrAttr>:$instanceName,          // Optional user name
    Variadic<AnyType>:$params                     // Optional parameter operands
  );
  let results = (outs Cal_Instance:$handle);
  let assemblyFormat = "$actorRef (`(` $params `:` type($params)^ `)`) ? (`instance` `(` $instanceName^ `)`)? attr-dict `:` type($handle)";
}

//===----------------------------------------------------------------------===//
// Instance array based symbolic construction (replaces connect.indexed)
//===----------------------------------------------------------------------===//

// We support grouping multiple actor instances created from the same actor
// symbol into an "instance array" so that users can index them directly in IR
// without having to materialize/scf loop-carried handles manually. This keeps
// replication patterns concise and amenable to later elaboration.
//
// The design introduces three new ops:
//  * cal.instantiate_array  -> produces a !cal.instance.array<@Actor> handle
//    with a statically known length (i64 attribute `count`).
//  * cal.instance_at        -> extracts a single !cal.instance<@Actor> handle
//    from the array given an index (either constant via arith.constant fed
//    as SSA or potentially dynamic). For now any index operand of type index
//    is accepted; verifier will ensure it is within bounds when the operand is
//    a constant.
//  * cal.connect            -> connects a source instance handle/port name to
//    a destination instance handle/port name. The assembly form allows the
//    sugar %arr[0] directly; the parser will lower this to an implicit
//    cal.instance_at followed by the connect (implemented in C++). In TableGen
//    we just define the base op on singular instance handles.
//
// NOTE: The previous cal.connect.indexed op is removed in favor of this more
// general, symmetric mechanism with optional array indexing on both ends.

// Forward declare the array type class name (defined in CalTypes.td in a later step).
// If not yet defined, add a TODO for implementers.
// Expected spelling: Cal_InstanceArray (mirrors Cal_Instance)

def Cal_InstantiateArrayOp : Cal_Op<"instantiate_array", [Pure]> {
  let summary = "Create an array of symbolic actor instance handles";
  let description = [{
    Allocates (symbolically) an array of N instances of @Actor. No FIFOs are
    created and no cal.create_instance ops are emitted yet. Each element can
    later be accessed using `cal.instance_at` or via the sugar `%arr[idx]` in
    `cal.connect` assembly. Intended for compact replication patterns.
  }];
  let arguments = (ins
    FlatSymbolRefAttr:$actorRef,          // Target actor symbol
    I64Attr:$count,                       // Number of instances in the array
    OptionalAttr<StrAttr>:$baseName,      // Optional base name for elements
    Variadic<AnyType>:$params             // Optional parameter operands
  );
  let results = (outs Cal_InstanceArray:$handlesArray);
  let assemblyFormat = "$actorRef `count` `(` $count `)` (`basename` `(` $baseName^ `)`)? (`(` $params `:` type($params)^ `)`) ? attr-dict `:` type($handlesArray)";
  let hasVerifier = 1;
  let hasCanonicalizer = 1;
}

def Cal_InstanceAtOp : Cal_Op<"instance_at", [Pure]> {
  let summary = "Extract a single instance handle from an instance array (ND indices)";
  let description = [{
    Given an instance array value and one or more index operands, produce the
    specific element instance handle. Indices support k-D access into
    multidimensional instance arrays. If all indices are constant, the verifier
    ensures they are within bounds. Dynamic indices are allowed but may inhibit
    some elaboration-time optimizations.
  }];
  // array expected: !cal.instance.array<...> or !cal.instance.array.iface<...>
  // indices: zero or more index-typed operands for ND indexing
  let arguments = (ins AnyType:$array, Variadic<Index>:$indices);
  // result: !cal.instance<@Actor> or !cal.instance.iface<@Iface>
  let results = (outs AnyType:$handle);
  let assemblyFormat = "$array `[` $indices `]` attr-dict `:` type($array) `->` type($handle)";
  let hasVerifier = 1;
}

// Interface-typed variant: produce an array of interface instance handles.
// Printed type form: !cal.instance.array.iface<@Iface, N>
def Cal_InstantiateArrayIfaceOp : Cal_Op<"instantiate_array.iface", [Pure]> {
  let summary = "Create an array of interface-typed instance handles";
  let description = [{
    Allocates (symbolically) an array of N instances typed by @Interface. No
    concrete entity is chosen here; elaboration will require resolution to
    concrete entities that implement the interface. Intended primarily for
    structural tests and interface wiring.
  }];
  let arguments = (ins
    FlatSymbolRefAttr:$ifaceRef,         // Target interface symbol
    I64Attr:$count,                      // Number of elements
    OptionalAttr<StrAttr>:$baseName,     // Optional base name for elements
    Variadic<AnyType>:$params            // Parameters are not supported; kept for syntax parity (must be empty).
  );
  let results = (outs Cal_InterfaceInstanceArray:$handlesArray);
  let assemblyFormat = "$ifaceRef `count` `(` $count `)` (`basename` `(` $baseName^ `)`)? (`(` $params `:` type($params)^ `)`) ? attr-dict `:` type($handlesArray)";
  let hasVerifier = 1;
}

def Cal_ConnectOp : Cal_Op<"connect", [AttrSizedOperandSegments]> {
  let summary = "Symbolic connection between two (possibly array-indexed) instances";
  let description = [{
    Declares a symbolic FIFO channel from a source actor instance handle to a
    destination actor instance handle, both identified via handles (possibly
    extracted from arrays) plus explicit port names. Alternatively, either side
    may directly reference a network port SSA value:
      - Source may be a `!fifo.output_port<T>` network input port (ports_in).
      - Destination may be a `!fifo.input_port<T>` network output port (ports_out).

    When a network port is used on one side, elaboration wires that SSA value
    directly to the corresponding actor port without creating an intermediate
    fifo. A fifo.create is only materialized when both endpoints are actor
    instance ports.

    Assembly sugar (to be implemented in the custom parser/printer) will allow:
       cal.connect %producers[0] "out" -> %consumers[3] "in0" capacity(8)
    which the parser lowers into:
       %p0 = cal.instance_at %producers[0]
       %c3 = cal.instance_at %consumers[3]
       cal.connect %p0 "out" -> %c3 "in0" capacity(8)
    The explicit form (without sugar) matches the assemblyFormat below.
  }];
  let arguments = (ins
    AnyType:$src,                    // !cal.instance/array or !fifo.output_port<...>
    Variadic<Index>:$srcIndices,     // Optional ND indices when src is an array handle
    StrAttr:$srcPort,                // Source output port name (ignored when src is a network port)
    AnyType:$dst,                    // !cal.instance/array or !fifo.input_port<...>
    Variadic<Index>:$dstIndices,     // Optional ND indices when dst is an array handle
    StrAttr:$dstPort,                // Destination input port name (ignored when dst is a network port)
    OptionalAttr<I64Attr>:$capacity  // Optional FIFO capacity / depth (used only when creating an intermediate fifo)
  );
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
  let hasCanonicalizer = 1;
}

//===----------------------------------------------------------------------===//
// Interface declaration and usage ops (stubs)
//===----------------------------------------------------------------------===//

// cal.interface @Name { ports_in(...), ports_out(...) }
// Minimal stub: capture port names and types as attributes for now.
def Cal_InterfaceOp : Cal_Op<"interface", [Symbol, NoTerminator, IsolatedFromAbove]> {
  let summary = "Declare a named interface with typed ports";
  let description = [{
    Declares an interface symbol that describes a set of typed ports. Concrete
    entities (actors or networks) may declare that they implement this
    interface, enabling interface-typed instance handles and arrays.
  }];
  let arguments = (ins
    SymbolNameAttr:$sym_name,
    OptionalAttr<ArrayAttr>:$inPortNames,
    OptionalAttr<ArrayAttr>:$inPortTypes,
    OptionalAttr<ArrayAttr>:$outPortNames,
    OptionalAttr<ArrayAttr>:$outPortTypes
  );
  let assemblyFormat = "$sym_name attr-dict";
  let hasVerifier = 1;
}

// cal.implements @Iface for @Entity
def Cal_ImplementsOp : Cal_Op<"implements", [NoTerminator, DeclareOpInterfaceMethods<SymbolUserOpInterface>]> {
  let summary = "Declare that an entity implements an interface";
  let description = [{
    Associates a concrete entity symbol (actor or network) with an interface
    symbol. Used for verification and for enabling interface-typed handles.
  }];
  let arguments = (ins
    FlatSymbolRefAttr:$ifaceRef,
    FlatSymbolRefAttr:$entityRef
  );
  let assemblyFormat = "$ifaceRef `for` $entityRef attr-dict";
}

// cal.instance.cast %h : !cal.instance<@E> -> !cal.instance.iface<@I>
def Cal_InstanceCastOp : Cal_Op<"instance.cast", [Pure]> {
  let summary = "Cast a concrete instance handle to an interface-typed handle";
  let description = [{
    Converts a concrete entity handle to an interface-typed handle. The cast is
    valid only if the concrete entity implements the interface.
  }];
  let arguments = (ins AnyType:$input);
  let results = (outs AnyType:$output);
  let assemblyFormat = "$input `:` type($input) `->` type($output) attr-dict";
  let hasVerifier = 1;
  let hasCanonicalizer = 1;
}

//===----------------------------------------------------------------------===//
// Finite State Machine (FSM) scheduling ops
// These ops allow expressing CAL-style schedule FSMs that select which
// cal.action may fire based on the current actor state. Guards remain inside
// actions via cal.predicate; priorities use the existing action priority.
//===----------------------------------------------------------------------===//

// cal.fsm
// Container of symbolic states. Exactly one contained cal.state must be initial.
def Cal_FsmOp : Cal_Op<"fsm", [HasParent<"ActorOp">, NoTerminator, SymbolTable]> {
  let summary = "Finite State Machine defining action scheduling for an actor";
  let description = [{
    The `cal.fsm` operation declares a finite state machine that schedules which
    `cal.action` may fire depending on the current symbolic state. Each state
    lists outgoing `cal.transition` edges to target states and labels them with
    an action name. A transition is enabled iff its referenced action is enabled
    (via that action's own `cal.predicate`s and data availability). Among enabled
    transitions, selection uses the referenced action's priority; ties are
    resolved by textual order of transitions.

    Exactly one contained `cal.state` must be marked as the initial state.
  }];

  let regions = (region AnyRegion:$body);

  // Keep assembly simple for the draft; `initial` appears in the state's attr-dict.
  let assemblyFormat = "$body attr-dict ";

  let hasVerifier = 1;
}

// cal.state
// Symbolic state inside an FSM. May be marked as `initial`.
def Cal_StateOp : Cal_Op<"state", [Symbol, HasParent<"FsmOp">, NoTerminator]> {
  let summary = "Symbolic state within a cal.fsm";
  let description = [{
    The `cal.state` operation declares a single symbolic state within a
    `cal.fsm`. Its region contains zero or more `cal.transition` operations.
    Exactly one state within an FSM must be designated as the initial state.
  }];

  let arguments = (ins
    SymbolNameAttr:$sym_name,
    OptionalAttr<UnitAttr>:$initial
  );

  let regions = (region AnyRegion:$body);

  // Draft assembly: state name then region; `initial` will appear in attr-dict if set.
  let assemblyFormat = "$sym_name $body attr-dict ";

  let hasVerifier = 1;
}

// cal.transition
// Transition from the enclosing state to `target`, labeled by `actionName`.
def Cal_TransitionOp : Cal_Op<"transition", [HasParent<"StateOp">, DeclareOpInterfaceMethods<SymbolUserOpInterface>]> {
  let summary = "Transition labeled by an action from a state to a target state";
  let description = [{
    The `cal.transition` operation defines a directed edge from the enclosing
    `cal.state` to a target state. The edge is labeled by `actionName`, which
    must name a `cal.action` defined in the same `cal.actor`. A transition is
    enabled exactly when that action is enabled. If fired, the action executes
    once and the FSM moves to the target state.
  }];

  let arguments = (ins
    StrAttr:$actionName,
    FlatSymbolRefAttr:$target
  );

  // Nice, parser-friendly assembly without custom C++.
  let assemblyFormat = "`action` `(` $actionName `)` `->` $target attr-dict ";

  let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// Array utilities
//===----------------------------------------------------------------------===//

// Construct a fixed-length instance array from a variadic list of instance
// handles. Homogeneity is checked by verifiers in downstream passes.
def Cal_InstanceArrayLiteralOp : Cal_Op<"instance_array.literal", [Pure]> {
  let summary = "Build an instance array from scalar handles";
  let description = [{
    Creates a `!cal.instance.array<@Entity, N>` from N scalar instance handles
    of the same entity (or interface) type.
  }];
  let arguments = (ins Variadic<AnyType>:$inputs);
  let results = (outs AnyType:$array);
  let assemblyFormat = "`(` $inputs `)` attr-dict `:` type($inputs) `->` type($array)";
  let hasVerifier = 1;
}

// Concatenate two instance arrays into a larger array. The element type must
// match (concrete entity or interface-typed) and sizes add up. Kept lightweight
// here; detailed checks can be performed in a later verifier or canonicalizer.
def Cal_InstanceArrayConcatOp : Cal_Op<"instance_array.concat", [Pure]> {
  let summary = "Concatenate two instance arrays";
  let description = [{
    Concatenates two instance arrays with the same element handle type into a
    single array whose length is the sum of the inputs.
  }];
  let arguments = (ins AnyType:$lhs, AnyType:$rhs);
  let results = (outs AnyType:$array);
  let assemblyFormat = "$lhs `,` $rhs attr-dict `:` type($lhs) `,` type($rhs) `->` type($array)";
  let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// Array construction helpers for scf-based comprehensions
//===----------------------------------------------------------------------===//

// cal.instance.array.init : create a fixed-shape array value (uninitialized)
// Example:
//   %arr = cal.instance.array.init : !cal.instance.array<@Actor, 4>
def Cal_InstanceArrayInitOp : Cal_Op<"instance.array.init", [Pure]> {
  let summary = "Create an uninitialized instance array value (optional dynamic dims)";
  let description = [{
    Produces a structural array value with the specified array type. Intended
    to be used as the initial iter_args value in scf.for when filling arrays
    using `cal.instance.array.set`.

    If the array type has dynamic dimensions, provide matching SSA index
    operands for its extents in order (e.g., (h, w) for a [h, w] array). For
    fully static shapes, the dims operands are optional.
  }];
  let arguments = (ins Variadic<Index>:$dims);
  let results = (outs AnyType:$array);
  let assemblyFormat = "(`(` $dims `:` type($dims)^ `)`) ? attr-dict `:` type($array)";
  // No custom verifier; structural checks are performed in dedicated passes.
  let hasCanonicalizer = 1;
}

// cal.instance.array.set : write one element and return a new array value
// Example (1D):
//   %arr2 = cal.instance.array.set %arr[%i], %h :
//            !cal.instance.array<@A, 4>, index, !cal.instance<@A>
// Example (kD):
//   %arr2 = cal.instance.array.set %arr[%i,%j], %h :
//            !cal.instance.array<@A, [2,2]>, index, index, !cal.instance<@A>
def Cal_InstanceArraySetOp : Cal_Op<"instance.array.set", [Pure]> {
  let summary = "Set one element in an instance array (returns new array value)";
  let description = [{
    Returns a new array value with the element at the provided index/indices
    set to the given instance handle. Type remains identical to the input
    array type, making it suitable for scf.for iter_args patterns.
  }];
  let arguments = (ins AnyType:$array, Variadic<Index>:$indices, AnyType:$value);
  let results = (outs AnyType:$result);
  let assemblyFormat = "$array `[` $indices `]` `,` $value attr-dict `:` type($array) `,` type($value) `->` type($result)";
  // No custom verifier/canonicalizer here; bounds/type checks are pass-driven.
}

//===----------------------------------------------------------------------===//
// Algebraic Type Operations: Variant (Sum Type) and Product Type
//===----------------------------------------------------------------------===//
// These operations support algebraic data types in CAL. Variants (sum types)
// represent tagged unions where each variant can hold different field types.
// Products represent structs/records with named fields.
//===----------------------------------------------------------------------===//

def Cal_VariantCreateOp : Cal_Op<"variant.create", [Pure]> {
  let summary = "Create a variant (sum type) value";
  let description = [{
    The `cal.variant.create` operation constructs a variant value with the
    specified variant name and field values. The result type must be a
    `!cal.variant` type, and the variant name must be one of the declared
    variants in that type.

    Arguments:
    - `variant_name`: The name of the variant being constructed (e.g., "Some", "None")
    - `fields`: Zero or more field values matching the variant's field types

    Results:
    - `result`: The constructed variant value

    Example:
      // Create a Some(42) value for Maybe<i32>
      %value = arith.constant 42 : i32
      %some = cal.variant.create "Some"(%value)
              : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>

      // Create a None value
      %none = cal.variant.create "None"()
              : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
  }];

  let arguments = (ins
    StrAttr:$variant_name,
    Variadic<AnyType>:$fields
  );

  let results = (outs Cal_Variant:$result);

  let assemblyFormat = [{
    $variant_name `(` $fields `)` attr-dict `:` type($result) (`(` type($fields)^ `)`)?
  }];

  let hasVerifier = 1;
}

def Cal_VariantGetTagOp : Cal_Op<"variant.get_tag", [Pure]> {
  let summary = "Get the discriminant tag of a variant value";
  let description = [{
    The `cal.variant.get_tag` operation extracts the discriminant tag from a
    variant value. The tag is returned as an index value representing which
    variant is currently active (0-indexed in declaration order).

    This operation is useful for pattern matching and conditional branching
    based on the variant type.

    Arguments:
    - `variant`: The variant value to extract the tag from

    Results:
    - `tag`: An index value representing the active variant (0 for first, etc.)

    Example:
      %maybe = ... : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
      %tag = cal.variant.get_tag %maybe : !cal.variant<"Maybe", ...> -> index
      // %tag is 0 if Some, 1 if None
  }];

  let arguments = (ins Cal_Variant:$variant);
  let results = (outs Index:$tag);

  let assemblyFormat = [{
    $variant attr-dict `:` type($variant) `->` type($tag)
  }];
}

def Cal_VariantGetFieldOp : Cal_Op<"variant.get_field", [Pure]> {
  let summary = "Extract a field value from a variant";
  let description = [{
    The `cal.variant.get_field` operation extracts a specific field value from
    a variant. The caller must specify which variant and which field index to
    extract. The behavior is undefined if the variant is not currently the
    specified variant (i.e., the tag doesn't match).

    This is typically used after checking the tag with `cal.variant.get_tag`
    to safely extract field values.

    Arguments:
    - `variant`: The variant value to extract from
    - `variant_name`: The expected active variant name
    - `field_index`: The 0-based index of the field to extract

    Results:
    - `result`: The extracted field value

    Example:
      %maybe = ... : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
      // Assumes %maybe is known to be Some
      %value = cal.variant.get_field %maybe["Some", 0]
               : !cal.variant<"Maybe", ...> -> i32
  }];

  let arguments = (ins
    Cal_Variant:$variant,
    StrAttr:$variant_name,
    I64Attr:$field_index
  );

  let results = (outs AnyType:$result);

  let assemblyFormat = [{
    $variant `[` $variant_name `,` $field_index `]` attr-dict
    `:` type($variant) `->` type($result)
  }];

  let hasVerifier = 1;
}

def Cal_VariantMatchOp : Cal_Op<"variant.match", [
    RecursiveMemoryEffects,
    SingleBlockImplicitTerminator<"VariantYieldOp">
  ]> {
  let summary = "Pattern match on a variant value";
  let description = [{
    The `cal.variant.match` operation provides structured pattern matching on
    variant (sum type) values. Each case region corresponds to one variant and
    receives the variant's fields as block arguments.

    The operation has one region per variant case. Each region must terminate
    with `cal.variant.yield` to produce a result value. All cases must yield
    values of the same type.

    Arguments:
    - `variant`: The variant value to match on

    Results:
    - `result`: The value yielded by the matching case

    Example:
      %maybe = ... : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
      %result = cal.variant.match %maybe : !cal.variant<"Maybe", ...> -> i32 {
        case "Some"(%v: i32):
          cal.variant.yield %v : i32
        case "None":
          %zero = arith.constant 0 : i32
          cal.variant.yield %zero : i32
      }

    Note: This high-level operation can be lowered to `scf.if` chains with
    `cal.variant.get_tag` and `cal.variant.get_field` operations.
  }];

  let arguments = (ins Cal_Variant:$variant);
  let results = (outs AnyType:$result);
  let regions = (region VariadicRegion<SizedRegion<1>>:$cases);

  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def Cal_VariantYieldOp : Cal_Op<"variant.yield", [
    Pure, Terminator,
    ParentOneOf<["VariantMatchOp"]>
  ]> {
  let summary = "Yield a result from a variant match case";
  let description = [{
    The `cal.variant.yield` operation terminates a case region within a
    `cal.variant.match` operation. It specifies the result value to be
    returned when that case is matched.

    Example:
      cal.variant.yield %value : i32
  }];

  let arguments = (ins AnyType:$result);

  let assemblyFormat = "$result attr-dict `:` type($result)";
}

//===----------------------------------------------------------------------===//
// Product Type Operations
//===----------------------------------------------------------------------===//

def Cal_ProductCreateOp : Cal_Op<"product.create", [Pure]> {
  let summary = "Create a product (struct/record) value";
  let description = [{
    The `cal.product.create` operation constructs a product type value from
    its field values. The fields must be provided in declaration order as
    specified in the product type definition.

    Arguments:
    - `fields`: The field values in declaration order

    Results:
    - `result`: The constructed product value

    Example:
      %x = arith.constant 10 : i32
      %y = arith.constant 20 : i32
      %vec = cal.product.create(%x, %y)
             : !cal.product<"Vec2", [("x", i32), ("y", i32)]>
  }];

  let arguments = (ins Variadic<AnyType>:$fields);
  let results = (outs Cal_Product:$result);

  let assemblyFormat = [{
    `(` $fields `)` attr-dict `:` type($result) (`:` `(` type($fields)^ `)`)?
  }];

  let hasVerifier = 1;
}

def Cal_ProductGetFieldOp : Cal_Op<"product.get_field", [Pure]> {
  let summary = "Extract a field value from a product type";
  let description = [{
    The `cal.product.get_field` operation extracts a named field from a product
    type value. The field name must be one of the declared fields in the
    product type definition.

    Arguments:
    - `product`: The product value to extract from
    - `field_name`: The name of the field to extract

    Results:
    - `result`: The extracted field value

    Example:
      %vec = ... : !cal.product<"Vec2", [("x", i32), ("y", i32)]>
      %x_val = cal.product.get_field %vec["x"]
               : !cal.product<"Vec2", ...> -> i32
  }];

  let arguments = (ins
    Cal_Product:$product,
    StrAttr:$field_name
  );

  let results = (outs AnyType:$result);

  let assemblyFormat = [{
    $product `[` $field_name `]` attr-dict `:` type($product) `->` type($result)
  }];

  let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// Memory Management Operations for Recursive Algebraic Types
// These operations implement the dataflow-specific memory model:
// - Arena: Action-scoped bump allocation for temporaries
// - RC: Reference-counted state variables
// - Token: Single-owner FIFO transfer
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Arena Operations
//===----------------------------------------------------------------------===//

def Cal_ArenaCreateOp : Cal_Op<"arena.create", [MemoryEffects<[MemAlloc]>]> {
  let summary = "Create a new memory arena for action-scoped allocations";
  let description = [{
    Creates a new bump-pointer arena for fast temporary allocations. The arena
    should be destroyed at action end using `cal.arena.destroy`.

    Optional `initial_size` specifies the initial arena capacity in bytes.
    The arena will grow automatically if needed.

    Example:
      %arena = cal.arena.create : !cal.arena
      %arena_big = cal.arena.create size(4096) : !cal.arena
  }];

  let arguments = (ins OptionalAttr<I64Attr>:$initial_size);
  let results = (outs Cal_Arena:$arena);

  let assemblyFormat = "(`size` `(` $initial_size^ `)`)? attr-dict `:` type($arena)";
}

def Cal_ArenaDestroyOp : Cal_Op<"arena.destroy", [MemoryEffects<[MemFree]>]> {
  let summary = "Destroy arena and free all allocations";
  let description = [{
    Destroys an arena, freeing all memory allocated from it. After this call,
    any pointers obtained from arena.alloc are invalid.

    This should be called at the end of each action to clean up temporaries.

    Example:
      cal.arena.destroy %arena : !cal.arena
  }];

  let arguments = (ins Cal_Arena:$arena);

  let assemblyFormat = "$arena attr-dict `:` type($arena)";
}

def Cal_ArenaAllocOp : Cal_Op<"arena.alloc", [MemoryEffects<[MemAlloc]>]> {
  let summary = "Allocate raw memory from arena";
  let description = [{
    Allocates raw memory from an arena with specified size and alignment.
    This is a low-level operation used by variant boxing operations.

    The returned pointer is valid until the arena is destroyed.

    Example:
      %ptr = cal.arena.alloc %arena[%size, align %align] : !cal.arena -> !llvm.ptr
  }];

  let arguments = (ins Cal_Arena:$arena, Index:$size, Index:$alignment);
  let results = (outs AnyType:$ptr);

  let assemblyFormat = "$arena `[` $size `,` `align` $alignment `]` attr-dict `:` type($arena) `->` type($ptr)";
}

//===----------------------------------------------------------------------===//
// Reference Counting Operations
//===----------------------------------------------------------------------===//

def Cal_RCAllocOp : Cal_Op<"rc.alloc", [MemoryEffects<[MemAlloc, MemWrite]>]> {
  let summary = "Allocate a reference-counted value (refcount = 1)";
  let description = [{
    Allocates a new reference-counted container holding the given value.
    The initial reference count is 1. The value is deep-copied into the
    RC container.

    Used for state variables containing recursive algebraic types.

    Example:
      %rc = cal.rc.alloc %list : !cal.variant<"List", ...> -> !cal.rc<!cal.variant<"List", ...>>
  }];

  let arguments = (ins AnyType:$value);
  let results = (outs Cal_RC:$result);

  let assemblyFormat = "$value attr-dict `:` type($value) `->` type($result)";

  let hasVerifier = 1;
}

def Cal_RCRetainOp : Cal_Op<"rc.retain", [MemoryEffects<[MemRead, MemWrite]>, SameOperandsAndResultType]> {
  let summary = "Increment reference count";
  let description = [{
    Increments the reference count of an RC container. Returns the same
    RC handle (for chaining convenience).

    Example:
      %rc2 = cal.rc.retain %rc : !cal.rc<i32>
  }];

  let arguments = (ins Cal_RC:$value);
  let results = (outs Cal_RC:$result);

  let assemblyFormat = "$value attr-dict `:` type($result)";

  let hasVerifier = 1;
}

def Cal_RCReleaseOp : Cal_Op<"rc.release", [MemoryEffects<[MemRead, MemWrite, MemFree]>]> {
  let summary = "Decrement reference count (free if zero)";
  let description = [{
    Decrements the reference count of an RC container. If the count
    reaches zero, the contained value and the container are freed.

    For recursive types, this recursively releases any nested RC values.

    Example:
      cal.rc.release %rc : !cal.rc<!cal.variant<"List", ...>>
  }];

  let arguments = (ins Cal_RC:$value);

  let assemblyFormat = "$value attr-dict `:` type($value)";

  let hasVerifier = 1;
}

def Cal_RCLoadOp : Cal_Op<"rc.load", [MemoryEffects<[MemRead]>]> {
  let summary = "Load value from RC container (borrow)";
  let description = [{
    Reads the value stored in an RC container without affecting the
    reference count. The returned value is a borrow - it is valid only
    as long as the RC container is alive.

    Example:
      %val = cal.rc.load %rc : !cal.rc<i32> -> i32
  }];

  let arguments = (ins Cal_RC:$rc);
  let results = (outs AnyType:$value);

  let assemblyFormat = "$rc attr-dict `:` type($rc) `->` type($value)";

  let hasVerifier = 1;
}

def Cal_RCStoreOp : Cal_Op<"rc.store", [MemoryEffects<[MemWrite]>]> {
  let summary = "Store a new value into RC container";
  let description = [{
    Replaces the value stored in an RC container. The old value is
    released (for recursive types, this decrements nested refcounts).

    Example:
      cal.rc.store %new_val into %rc : i32 into !cal.rc<i32>
  }];

  let arguments = (ins AnyType:$value, Cal_RC:$rc);

  let assemblyFormat = "$value `into` $rc attr-dict `:` type($value) `into` type($rc)";

  let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// Token Operations (FIFO Transfer)
//===----------------------------------------------------------------------===//

def Cal_TokenWrapOp : Cal_Op<"token.wrap", [MemoryEffects<[MemAlloc, MemRead, MemWrite]>]> {
  let summary = "Wrap a value into a token for FIFO transfer (deep copy)";
  let description = [{
    Creates a token by deep-copying the value. The source value remains
    valid (until its arena is destroyed), but the token now owns an
    independent copy suitable for FIFO transfer.

    The optional `source_arena` operand indicates where the source value
    lives, enabling optimized copying strategies.

    Example:
      %token = cal.token.wrap %list : !cal.variant<"List", ...> 
               -> !cal.token<!cal.variant<"List", ...>>
      
      %token2 = cal.token.wrap %list from %arena 
                : !cal.variant<"List", ...> -> !cal.token<!cal.variant<"List", ...>>
  }];

  let arguments = (ins AnyType:$value, Optional<Cal_Arena>:$source_arena);
  let results = (outs Cal_Token:$token);

  let assemblyFormat = [{
    $value (`from` $source_arena^)? attr-dict `:` type($value) `->` type($token)
  }];

  let hasVerifier = 1;
}

def Cal_TokenUnwrapOp : Cal_Op<"token.unwrap", [MemoryEffects<[MemRead, MemWrite, MemFree]>]> {
  let summary = "Unwrap a token into target arena (consumes token)";
  let description = [{
    Extracts the value from a token into the target arena. The token is
    consumed and cannot be used again. This is typically zero-copy as
    the token's memory can be adopted by the arena.

    Example:
      %val = cal.token.unwrap %token into %arena 
             : !cal.token<!cal.variant<"List", ...>> -> !cal.variant<"List", ...>
  }];

  let arguments = (ins Cal_Token:$token, Cal_Arena:$target_arena);
  let results = (outs AnyType:$value);

  let assemblyFormat = [{
    $token `into` $target_arena attr-dict `:` type($token) `->` type($value)
  }];

  let hasVerifier = 1;
}

def Cal_TokenConsumeOp : Cal_Op<"token.consume", [MemoryEffects<[MemFree]>]> {
  let summary = "Consume and discard a token without unwrapping";
  let description = [{
    Destroys a token without extracting its value. Use this when a
    received token is not needed (e.g., error handling paths).

    Example:
      cal.token.consume %token : !cal.token<!cal.variant<"List", ...>>
  }];

  let arguments = (ins Cal_Token:$token);

  let assemblyFormat = "$token attr-dict `:` type($token)";
}

//===----------------------------------------------------------------------===//
// Boxing Operations (for recursive variant fields)
//===----------------------------------------------------------------------===//

def Cal_BoxInArenaOp : Cal_Op<"box.in_arena", [MemoryEffects<[MemAlloc, MemWrite]>]> {
  let summary = "Box a value in an arena (for recursive variant fields)";
  let description = [{
    Allocates memory in the arena and stores the value there. Returns a
    pointer to the boxed value. Used internally for recursive variant
    fields that cannot be stored inline.

    Example:
      %boxed = cal.box.in_arena %list in %arena 
               : !cal.variant<"List", ...> -> !llvm.ptr
  }];

  let arguments = (ins AnyType:$value, Cal_Arena:$arena);
  let results = (outs AnyType:$boxed);

  let assemblyFormat = "$value `in` $arena attr-dict `:` type($value) `->` type($boxed)";
}

def Cal_UnboxOp : Cal_Op<"unbox", [MemoryEffects<[MemRead]>]> {
  let summary = "Unbox a pointer to retrieve the value";
  let description = [{
    Loads and returns the value stored at a boxed pointer. The pointer
    must be valid (pointing to live arena or RC memory).

    Example:
      %val = cal.unbox %ptr : !llvm.ptr -> !cal.variant<"List", ...>
  }];

  let arguments = (ins AnyType:$boxed);
  let results = (outs AnyType:$value);

  let assemblyFormat = "$boxed attr-dict `:` type($boxed) `->` type($value)";
}

//===----------------------------------------------------------------------===//
// Deep Copy Operation (generated per-type for recursive structures)
//===----------------------------------------------------------------------===//

def Cal_DeepCopyOp : Cal_Op<"deep_copy", [MemoryEffects<[MemAlloc, MemRead, MemWrite]>]> {
  let summary = "Deep copy a value into target arena";
  let description = [{
    Creates a deep copy of a value, allocating all recursive components
    in the target arena. This is used when transferring data between
    arenas (e.g., for FIFO token wrapping).

    For non-recursive types, this is a simple copy. For recursive types,
    all nested boxed values are recursively copied.

    Example:
      %copy = cal.deep_copy %list into %arena 
              : !cal.variant<"List", ...> in !cal.arena -> !cal.variant<"List", ...>
  }];

  let arguments = (ins AnyType:$value, Cal_Arena:$target_arena);
  let results = (outs AnyType:$copy);

  let assemblyFormat = [{
    $value `into` $target_arena attr-dict 
    `:` type($value) `in` type($target_arena) `->` type($copy)
  }];
}

#endif // CAL_OPS
