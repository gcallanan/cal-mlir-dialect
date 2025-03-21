//===- FifoOps.td - Fifo dialect ops -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FIFO_OPS
#define FIFO_OPS

include "Fifo/FifoTypes.td"
include "mlir/IR/OpBase.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/SymbolInterfaces.td"


// TODO: Need to update this description with an example
// TODO: What traits should this function have?
def Fifo_CreateOp : Fifo_Op<"create", []> {
  let summary = "Creates a FIFO buffer of a given size and element type";
  let description = [{
    The `fifo.create` operation creates a FIFO buffer with a specified size 
    and element type. The size is provided as an integer attribute, and the 
    element type is specified as a type parameter. 

    Outputs:

    Example:
  }];

  let arguments = (ins 
    TypeAttr:$elementType, // The type of the elements in the FIFO buffer
    I64Attr:$size // The size of the FIFO buffer
  );

  let results = (outs 
    AnyType:$inputPort,   // Input port result
    AnyType:$outputPort  // Output port result
  );

  let assemblyFormat = "`<` $elementType `>` `(` $size `)` attr-dict `:` type($inputPort) `,` type($outputPort)";

  //let hasVerifier = 1; // Enables verification logic in C++.
}

#endif // FIFO_OPS
