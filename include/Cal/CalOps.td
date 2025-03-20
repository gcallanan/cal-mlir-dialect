//===- CalOps.td - Cal dialect ops -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef CAL_OPS
#define CAL_OPS

include "Cal/CalTypes.td"
include "mlir/IR/OpBase.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/SymbolInterfaces.td"


def Cal_ActorOp : Cal_Op<"actor", [Symbol]> {
  let summary = "CAL actor operation";
  let description = [{
    Represents an actor that contains one or more action regions. Each region 
    must contain exactly one cal.action operation.
    
    This operation has the folloing interfaces:
    - [Symbol]: This actor needs to have a name and this name needs to be part 
                of the symbol table so that it can be accessed from other
                locations.
  }];

  let arguments = (ins
    SymbolNameAttr:$sym_name // Actor Name: Required by the Symbol interface
  );

  let assemblyFormat = "$sym_name`{` attr-dict `}` ";
}

def Cal_ActionOp : Cal_Op<"action"> {
  let summary = "CAL action operation";
  let description = [{
    Represents an individual action within a cal.actor.
  }];

  let assemblyFormat = "`{` attr-dict `}` ";  // Adjust as needed.
}


// I need to get rid of this. Its just here from the original template, but it
// requires that I modify some things in the MLIR codebase that I have not yet
// done:
def Cal_FooOp : Cal_Op<"foo", [Pure,
                                             SameOperandsAndResultType]> {
    let summary = "Illustrates how to define an operation.";
    let description = [{
        The `cal.foo` operation illustrates how to define a new
        operation in a dialect. It uses an operation trait to declare that it
        has no side effects.

        This operation takes an integer argument and returns an integer.

        Example:

        ```mlir
        %0 = arith.constant 2 : i32
        // Apply the foo operation to %0
        %1 = cal.foo %0 : i32
        ```
    }];

    let arguments = (ins I32:$input);
    let results = (outs I32:$res);

    let assemblyFormat = [{
        $input attr-dict `:` type($input)
    }];
}

#endif // CAL_OPS
