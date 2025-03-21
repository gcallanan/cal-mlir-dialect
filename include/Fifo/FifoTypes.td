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
include "Fifo/FifoDialect.td"

//===----------------------------------------------------------------------===//
// Fifo type definitions
//===----------------------------------------------------------------------===//

class Fifo_Type<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<Fifo_Dialect, name, traits> {
  let mnemonic = typeMnemonic;
}

def Fifo_CustomType : Fifo_Type<"Custom", "custom"> {
    let summary = "Fifo custom type";
    let description = "Custom type in cal dialect";
    let parameters = (ins StringRefParameter<"the custom value">:$value);
    let assemblyFormat = "`<` $value `>`";
}

#endif // FIFO_TYPES
