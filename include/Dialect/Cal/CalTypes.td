//===- CalTypes.td - Cal dialect types -------*- tablegen -*-===//
//
// This file is licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef CAL_TYPES
#define CAL_TYPES

include "mlir/IR/AttrTypeBase.td"
include "Dialect/Cal/CalDialect.td"

//===----------------------------------------------------------------------===//
// Cal type definitions
//===----------------------------------------------------------------------===//

class Cal_Type<string name, string typeMnemonic, list<Trait> traits = []>
    : TypeDef<Cal_Dialect, name, traits> {
  let mnemonic = typeMnemonic;
}

def Cal_CustomType : Cal_Type<"Custom", "custom"> {
    let summary = "Cal custom type";
    let description = "Custom type in cal dialect";
    let parameters = (ins StringRefParameter<"the custom value">:$value);
    let assemblyFormat = "`<` $value `>`";
}

#endif // CAL_TYPES
