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

def Cal_ActorOp : Cal_Op<"actor", [Symbol, IsolatedFromAbove, NoTerminator, AttrSizedOperandSegments]> {
  let summary = "CAL actor operation";
  let description = [{
    Represents an actor that contains one or more action regions. Each region
    must contain exactly one cal.action operation.
  }];

  let arguments = (ins
    SymbolNameAttr:$sym_name, // Actor Name: Required by the Symbol interface
    Variadic<Fifo_InputPort>:$input_ports,
    Variadic<Fifo_OutputPort>:$output_ports
  );

  let assemblyFormat = "$sym_name\n(`input_ports` `(` $input_ports^ `:` type($input_ports) `)`)?\n(`output_ports` `(` $output_ports^ `:` type($output_ports) `)`)? attr-dict";
}

def Cal_ActionOp : Cal_Op<"action"> {
  let summary = "CAL action operation";
  let description = [{
    Represents an individual action within a cal.actor.
  }];

  let assemblyFormat = "`{` attr-dict `}` ";  // Adjust as needed.
}

#endif // CAL_OPS
