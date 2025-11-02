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
// Unified ND array of symbolic instance handles (dynamic-friendly).
// Printed form: !cal.instance.array<@Actor, [d0, d1, ..., dk]>
// Each di may be an integer or the dynamic marker '?'. The parser/printer
// map '?' to a sentinel (e.g., -1) internally.
def Cal_InstanceArray : Cal_Type<"InstanceArray", "instance.array", []> {
  let summary = "ND array of symbolic actor instance handles (supports dynamic dims)";
  let description = [{
    Represents an ND array of symbolic instances of @Actor. The shape list may
    contain dynamic dimensions denoted by '?'. Structural passes may keep shapes
    symbolic until elaboration or specialize when constants are available.
  }];
  let parameters = (ins "mlir::FlatSymbolRefAttr":$actorRef, "mlir::ArrayAttr":$shape);
  let hasCustomAssemblyFormat = 1;
}

// -------------------------------------------------------------------------- //
// Interface-typed scalar instance handle. Printed form:
//   !cal.instance.iface<@MyIface>
def Cal_InterfaceInstance : Cal_Type<"InterfaceInstance", "instance.iface", []> {
  let summary = "Handle to a symbolic instance typed by an interface";
  let description = [{
    A handle designating an entity instance by interface conformance rather
    than a specific symbol. Any actor or network that declares implementation
    of the referenced interface may back this handle.
  }];
  let parameters = (ins "mlir::FlatSymbolRefAttr":$ifaceRef);
  let assemblyFormat = "`<` $ifaceRef `>`";
}

// Fixed-length array of interface-typed instance handles.
//   !cal.instance.array.iface<@MyIface, N>
// Unified ND array of interface-typed instance handles.
// Printed form: !cal.instance.array.iface<@Iface, [d0, ..., dk]>
def Cal_InterfaceInstanceArray : Cal_Type<"InterfaceInstanceArray", "instance.array.iface", []> {
  let summary = "ND array of interface-typed instance handles (supports dynamic dims)";
  let description = [{
    Represents an ND array whose elements are handles typed by an interface. The
    shape list may include dynamic dimensions denoted by '?'. Elements may refer
    to different concrete entities that implement the interface.
  }];
  let parameters = (ins "mlir::FlatSymbolRefAttr":$ifaceRef, "mlir::ArrayAttr":$shape);
  let hasCustomAssemblyFormat = 1;
}

// Unknown-length homogeneous collections (entity or interface).
//   !cal.instances<@Actor>
//   !cal.instances.iface<@Iface>
def Cal_Instances : Cal_Type<"Instances", "instances", []> {
  let summary = "Unknown-length collection of entity-typed handles";
  let parameters = (ins "mlir::FlatSymbolRefAttr":$actorRef);
  let assemblyFormat = "`<` $actorRef `>`";
}

def Cal_InterfaceInstances : Cal_Type<"InterfaceInstances", "instances.iface", []> {
  let summary = "Unknown-length collection of interface-typed handles";
  let parameters = (ins "mlir::FlatSymbolRefAttr":$ifaceRef);
  let assemblyFormat = "`<` $ifaceRef `>`";
}

#endif // CAL_TYPES
