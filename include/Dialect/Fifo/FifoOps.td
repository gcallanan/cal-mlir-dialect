//===- FifoOps.td - Fifo dialect ops -----------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FIFO_OPS
#define FIFO_OPS

include "Dialect/Fifo/FifoTypes.td"
include "mlir/IR/OpBase.td"
include "mlir/Interfaces/InferTypeOpInterface.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/SymbolInterfaces.td"



// TODO: Need to update this description with an example
// TODO: What traits should this function have?
def Fifo_CreateOp : Fifo_Op<"create", []> {
  let summary = "Creates a FIFO buffer of a given size and element type";
  let description = [{
    The `fifo.create` operation initializes a FIFO buffer with a given size
    and element type. The buffer allows data to be pushed in and popped out
    in a first-in, first-out manner.

    Arguments:
    - `elementType`: Specifies the type of elements stored in the FIFO.
    - `buffer_size`: Defines the maximum number of elements the FIFO can hold.

    Results:
    - `inputPort`: Used for pushing elements into the FIFO.
    - `outputPort`: Used for popping elements from the FIFO.

    Example:
    %input_port, %output_port = fifo.create<f32>(64): !fifo.input_port<i32>, !fifo.output_port<i32>
    This creates a FIFO buffer that stores `f32` values and has a capacity of 64 elements.

    Description originally written by Gareth Callanan and refined using ChatGPT.
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

def Fifo_Pop : Fifo_Op<"pop", [MemoryEffects<[MemRead]>]> {
  let summary = "Pop a token from the front of the FIFO buffer";
  let description = [{
    The `fifo.pop` operation retrieves an element from the front of the FIFO
    buffer via the `outputPort`. This operation ensures that the FIFO maintains
    its sequential ordering, where the first element pushed is the first one popped.

    Arguments:
    - `outputPort`: A handle to the FIFO buffer's output port, from which an element will be retrieved.

    Results:
    - `outputToken`: The element removed from the FIFO buffer.

    Example:
    %token = fifo.pop(%outputPort : !fifo.output_port<i32>): i32
    This pops an element from the FIFO buffer associated with `%outputPort`.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];

  let arguments = (ins
    AnyType:$outputPort // The output port targeted for the pop operation
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
    The `fifo.push` operation inserts a new element into the FIFO buffer via the
    `inputPort`. The element is stored in the buffer until it is retrieved by
    a `fifo.pop` operation.

    Arguments:
    - `inputToken`: The value being pushed into the FIFO.
    - `inputPort`: The port associated with the FIFO buffer where the value is pushed.

    Example:
    fifo.push(%token: i32, %inputPort: !fifo.input_port<i32>)
    This pushes `%token` into the FIFO buffer at `%inputPort`.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];

  let arguments = (ins
    AnyType:$inputToken, // The token to push to the FIFO buffer
    AnyType:$inputPort // The input port targeted for the push operation
  );

  let assemblyFormat = "`(` $inputPort `:` type($inputPort) `,` $inputToken `:` type($inputToken)  `)` attr-dict";

  let hasVerifier = 1; // Enables verification logic in C++.
}

def Fifo_GetTupleElement: Fifo_Op<"get_tuple_element", []> {
  let description = [{
    The `fifo.get_tuple_element` operation extracts an element from a tuple at a
    specified index. Typically this is used when converting the FIFO dialect to
    to a lower dialect like memref as often multiple memrefs will represent a
    single port and these need to be stored in a tuple. MLIR defines tuples
    but not how to use them, so we need to have this operation here.

    Arguments:
    - A tuple containing multiple elements.
    - `index`: An integer attribute specifying the position of the element to extract.

    Results:
    - The extracted element from the tuple.

    Example:
    %element = fifo.get_tuple_element(%tuple, 1)
    This retrieves the second element (index `1`) from `%tuple`

    NOTE: It would make more sense for this operation to go into some utility
    dialect instead of fifo as it is useful in multiple dialects, but for now
    it stays here.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];

  let arguments = (ins
    TupleOf<[AnyType]>:$tupleName,
    I32Attr:$index
  );
  let results = (outs AnyType:$output);

  let assemblyFormat = "$tupleName `[` $index `]` attr-dict `:` type($tupleName) `->` type($output)";
}

def Fifo_MakeTuple: Fifo_Op<"make_tuple", []> {
  let description = [{
    The `fifo.make_tuple` operation constructs a tuple from multiple input values.
    This is useful for grouping multiple related values into a single data structure.
    Typically this is used when converting the FIFO dialect to
    to a lower dialect like memref as often multiple memrefs will represent a
    single port and these need to be stored in a tuple. MLIR defines tuples
    but not how to use them, so we need to have this operation here.

    Arguments:
    - A variadic list of input values to form the tuple.

    Results:
    - A tuple containing all input values.

    Example:
    %tuple = fifo.make_tuple(%a, %b)
    This creates a tuple containing `%a`, `%b`, and `%c`.

    NOTE: It would make more sense for this operation to go into some utility
    dialect instead of fifo as it is useful in multiple dialects, but for now
    it stays here.

    Description originally written by Gareth Callanan and refined using ChatGPT.
  }];

  let arguments = (ins
    Variadic<AnyType>:$inputs
  );
  let results = (outs TupleOf<[AnyType]>:$output);

  let assemblyFormat = "`(` $inputs `)` attr-dict `:` type($inputs) `->` type($output)";
}

def Fifo_PrintOp : Fifo_Op<"print", []> {
  let summary = "Prints formatted output with variadic arguments.";
  let description = [{
    The `fifo.print` operation takes a format string followed by a variadic list of arguments,
    similar to the standard `printf` function in C.

    Example:
      %c1 = arith.constant 1 : i32
      %c2 = arith.constant 2 : i32

      fifo.print("A simple print!\0A\00")
      fifo.print("Value: %d\0A\00", %c1) : (i32)
      fifo.print("Values: %d %d\0A\00", %c1, %c2) : (i32, i32)

    NOTE: f32 values need to be explicitly cast to an f64 value as the %f
    in the format string requires a 64-bit floating point value. The program
    will still run if you pass an f32 into fifo print, but it will not
    print out the expected value.

    NOTE 2: It would make more sense for this operation to go into some utility
    dialect instead of fifo as it is useful in multiple dialects, but for now
    it stays here.
  }];

  let arguments = (ins
    StrAttr:$format,
    Variadic<AnyType>:$args
  );

  let assemblyFormat = "`(` $format (`,` $args^)? `)` attr-dict (`:` `(` type($args)^ `)`)?";
}



#endif // FIFO_OPS
