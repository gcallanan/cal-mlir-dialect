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
    I64Attr:$buffer_size // The size of the FIFO buffer
  );

  let results = (outs 
    AnyType:$inputPort,   // Input port result
    AnyType:$outputPort  // Output port result
  );

  let assemblyFormat = "`<` $elementType `>` `(` $buffer_size `)` attr-dict `:` type($inputPort) `,` type($outputPort)";

  let hasVerifier = 1; // Enables verification logic in C++.
}

def Fifo_Pull : Fifo_Op<"pull", [MemoryEffects<[MemRead]>]> {
  let summary = "Pull a token from the front of the FIFO buffer";
  let description = [{
    TODO

    Has the trait MemoryEffects<[MemRead]> which indicates that the operation
    reads from memory. (Not 100% sure if this is correct)
  }];

  let arguments = (ins
    AnyType:$outputPort // The output port targeted for the pull operation
  );

  let results = (outs
    AnyType:$outputToken   // The token we pop from the FIFO buffer
  );

  let assemblyFormat = "`(` $outputPort `:` type($outputPort) `)` attr-dict `:` type($outputToken)";

  let hasVerifier = 1; // Enables verification logic in C++.
}

def Fifo_Push : Fifo_Op<"push", [MemoryEffects<[MemWrite]>]> {
  let summary = "Push a token to the back of the FIFO buffer";
  let description = [{
    Has the trait MemoryEffects<[MemWrite]> which indicates that the operation
    writes to memory. (Not 100% sure if this is correct)
  }];

  let arguments = (ins
    AnyType:$inputToken, // The token to push to the FIFO buffer
    AnyType:$inputPort // The input port targeted for the push operation
  );


  let assemblyFormat = "`(` $inputPort `:` type($inputPort) `,` $inputToken `:` type($inputToken)  `)` attr-dict";

  let hasVerifier = 1; // Enables verification logic in C++.
}


#endif // FIFO_OPS
