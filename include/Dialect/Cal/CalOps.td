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
//    - [AttrSizedOperandSegments]: We have multiple variadic arguments
//                                  (The $output_ports and $input_ports). MLIR
//                                  requires that we specify something about the
//                                  size of these arguments. This trait specifies
//                                  that there is no relationship between these
//                                  arguments and that they can be of any size.
//
//

def Cal_ActorOp : Cal_Op<"actor", [Symbol, IsolatedFromAbove, NoTerminator]> {
  let summary = "CAL actor operation";
  let description = [{
    Represents an actor that contains one or more action regions. Each region
    must contain exactly one cal.action operation.
  }];

  let arguments = (ins
    SymbolNameAttr:$sym_name // Actor Name: Required by the Symbol interface
  );

  let regions = (region AnyRegion:$body);

  //let assemblyFormat = "$sym_name  `(` $input_port `)`  ( $body^ )? attr-dict ";
  let hasCustomAssemblyFormat = 1;
}

def CAL_ActionDoneOp : Cal_Op<"action_done", [Terminator]> {
  let summary = "TODO";
  let description = [{
    TODO
  }];

  let assemblyFormat = "attr-dict";
}

def CAL_ActionNotDoneOp : Cal_Op<"action_not_done", [Terminator]> {
  let summary = "TODO";
  let description = [{
    TODO
  }];

  let assemblyFormat = "attr-dict";
}

def Cal_ActionOp : Cal_Op<"action", [HasParent<"ActorOp">]> {
  let summary = "CAL action operation";
  let description = [{
    Represents an individual action within a cal.actor.
  }];

  let regions = (region AnyRegion:$body);

  let assemblyFormat = "$body attr-dict ";
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
