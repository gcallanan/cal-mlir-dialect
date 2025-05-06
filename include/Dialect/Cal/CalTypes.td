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

def Cal_StateVarRef : Cal_Type<"StateVarRef", "state_ref", []> {
    let summary = "Reference to an actor state variable";
    let description = [{
      This type is used to reference an actor state variable. It is used in
      operations that need to access the value of a state variable.
    }];
    let parameters = (ins "Type":$stateType);
    let assemblyFormat = "`<` $stateType `>`";
}

#endif // CAL_TYPES
