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

// -------------------------------------------------------------------------- //
// Symbolic instance handle type (Step 1 of network elaboration work).
// Carries a reference to the actor symbol it will eventually instantiate.
// High level structural ops produce this type; an elaboration pass lowers
// them to concrete fifo.create + cal.create_instance.
// Example printed form: !cal.instance<@MyActor>
// NOTE: The parameter is a FlatSymbolRefAttr; the actual symbol must point to
// a cal.actor op. Verification happens in C++ (not yet implemented).
def Cal_Instance : Cal_Type<"Instance", "instance", []> {
  let summary = "Handle to a symbolic actor instance (pre-elaboration)";
  let description = [{
    A lightweight handle designating an actor to be instantiated inside a
    `cal.network`. This handle is produced by high-level structural ops such
    as `cal.instantiate` and consumed by connection ops (e.g.
    `cal.connect.indexed`). During elaboration these handles are replaced by
    concrete `cal.create_instance` operations and the intermediate structural
    ops are removed.
  }];
  let parameters = (ins "mlir::FlatSymbolRefAttr":$actorRef);
  let assemblyFormat = "`<` $actorRef `>`";
}

// -------------------------------------------------------------------------- //
// Array of symbolic instance handles. Parameterized by the target actor
// symbol and a static element count. Printed form:
//   !cal.instance.array<@MyActor, 8>
// This mirrors the single handle but enables concise replication patterns
// and indexed extraction via `cal.instance_at`.
def Cal_InstanceArray : Cal_Type<"InstanceArray", "instance.array", []> {
  let summary = "Array of symbolic actor instance handles";
  let description = [{
    Represents N symbolic instances of a given actor @Actor. Produced by
    `cal.instantiate_array @Actor count(<N>)` and consumed by
    `cal.instance_at` (or syntactic sugar %arr[<i>] in `cal.connect`). The
    elaboration pass expands this structure into N concrete
    `cal.create_instance` ops and corresponding FIFO creations.
  }];
  let parameters = (ins "mlir::FlatSymbolRefAttr":$actorRef, "int":$count);
  let assemblyFormat = "`<` $actorRef `,` $count `>`";
}

#endif // CAL_TYPES
