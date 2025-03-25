//===- FifoTypes.td - Fifo dialect types -------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FIFO_TYPES
#define FIFO_TYPES

include "mlir/IR/AttrTypeBase.td"
include "Dialect/Fifo/FifoDialect.td"

//===----------------------------------------------------------------------===//
// Fifo type definitions
//===----------------------------------------------------------------------===//

// This is the base type definition for all types in the Fifo dialect.
// - string name represents the name of the type in the generated C++ code.
// - string typeMnemonic represents the name of the type used in the .mlir files.
// - list<Trait> traits is a list of traits that the type conforms to.
class Fifo_Type<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<Fifo_Dialect, name, traits> {
  let mnemonic = typeMnemonic;
}

def Fifo_InputPort : Fifo_Type<"InputPort", "input_port", []> {
    let summary = "Input port to a FIFO channel";
    let description = [{
      Type that represents the input port of FIFO channel.
    }];
    let parameters = (ins "Type":$elementType);
    let assemblyFormat = "`<` $elementType `>`";
}

def Fifo_OutputPort : Fifo_Type<"OutputPort", "output_port", []> {
    let summary = "Output port to a FIFO channel";
    let description = [{
      Type that represents the output port of FIFO channel.
    }];
    let parameters = (ins "Type":$elementType);
    let assemblyFormat = "`<` $elementType `>`";
}

#endif // FIFO_TYPES
