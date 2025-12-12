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

//===----------------------------------------------------------------------===//
// Algebraic Types: Variant (Sum Type) and Product Type
//===----------------------------------------------------------------------===//

def Cal_Variant : Cal_Type<"Variant", "variant", []> {
  let summary = "Algebraic sum type (tagged union)";
  let description = [{
    Represents a sum type with named variants, each containing zero or more fields.
    This type models tagged unions where each variant can hold different field types.

    The type is parameterized by:
    - `name`: A string identifying the type (e.g., "Maybe", "Result")
    - `variants`: An ArrayAttr of DictionaryAttr, each containing:
      - "name": StringAttr for the variant name (e.g., "Some", "None")
      - "fields": ArrayAttr of Type for the variant's field types

    Example printed forms:
      !cal.variant<"Maybe", [#cal.var<"Some", [i32]>, #cal.var<"None", []>]>
      !cal.variant<"Result", [#cal.var<"Ok", [tensor<2x2xf32>]>, #cal.var<"Err", [i32]>]>

    Usage in CAL:
      type Maybe(type T):
        Some(T value)
      | None
      end

    Memory layout (for lowering): A struct with a tag field (i32) followed by
    a union of all variant payloads (size = max variant size).
  }];
  let parameters = (ins
    StringRefParameter<"type name">:$name,
    "mlir::ArrayAttr":$variants
  );
  let hasCustomAssemblyFormat = 1;
  let genVerifyDecl = 1;
}

def Cal_Product : Cal_Type<"Product", "product", []> {
  let summary = "Algebraic product type (record/struct)";
  let description = [{
    Represents a product type with named fields. This is similar to a struct
    or record type in other languages.

    The type is parameterized by:
    - `name`: A string identifying the type (e.g., "Vec2", "Point3D")
    - `fields`: An ArrayAttr of DictionaryAttr, each containing:
      - "name": StringAttr for the field name (e.g., "x", "y")
      - "type": TypeAttr for the field type

    Example printed forms:
      !cal.product<"Vec2", [#cal.field<"x", i32>, #cal.field<"y", i32>]>
      !cal.product<"Point3D", [#cal.field<"x", f64>, #cal.field<"y", f64>, #cal.field<"z", f64>]>

    Usage in CAL:
      type Vec2:
        (int x, int y)
      end

    Memory layout: A struct with fields in declaration order.
  }];
  let parameters = (ins
    StringRefParameter<"type name">:$name,
    "mlir::ArrayAttr":$fields
  );
  let hasCustomAssemblyFormat = 1;
  let genVerifyDecl = 1;
}

//===----------------------------------------------------------------------===//
// Memory Management Types for Recursive Algebraic Types
// These types support the dataflow-specific memory management model:
// - Arena: Action-scoped bump allocation
// - RC: Reference-counted state variables
// - Token: Single-owner FIFO transfer
//===----------------------------------------------------------------------===//

def Cal_Arena : Cal_Type<"Arena", "arena", []> {
  let summary = "Action-scoped memory arena for temporary allocations";
  let description = [{
    Represents a bump-pointer arena for fast allocation of temporary values.
    Arenas are created at action start and destroyed at action end. All
    allocations within an arena are freed together when the arena is destroyed.

    This type is used for:
    - Temporary recursive variant allocations within actions
    - Intermediate computation results
    - Deep copies during FIFO token wrapping

    Example usage:
      %arena = cal.arena.create : !cal.arena
      %ptr = cal.arena.alloc %arena[64, align 8] : !llvm.ptr
      cal.arena.destroy %arena : !cal.arena
  }];
  // No parameters - arena is an opaque handle
}

def Cal_RC : Cal_Type<"RC", "rc", []> {
  let summary = "Reference-counted heap allocation for state variables";
  let description = [{
    Wraps a value with reference counting for state variables that persist
    across action firings. The reference count is stored alongside the value
    and automatically manages memory deallocation.

    This type is used for:
    - State variables containing recursive types
    - Shared data that outlives a single action

    The element type can be any MLIR type, including recursive variants.

    Example printed forms:
      !cal.rc<i32>
      !cal.rc<!cal.variant<"List", ...>>

    Operations:
      %rc = cal.rc.alloc %value : T -> !cal.rc<T>    // refcount = 1
      %rc2 = cal.rc.retain %rc : !cal.rc<T>          // refcount++
      cal.rc.release %rc : !cal.rc<T>                // refcount--, free if 0
      %val = cal.rc.load %rc : !cal.rc<T> -> T       // read value
  }];
  let parameters = (ins "Type":$elementType);
  let assemblyFormat = "`<` $elementType `>`";
}

def Cal_Token : Cal_Type<"Token", "token", []> {
  let summary = "Owned data token for FIFO transfer with single ownership";
  let description = [{
    Represents data being transferred through a FIFO with single ownership.
    Tokens are created by wrapping arena or RC values (deep copy), and
    consumed by unwrapping into the receiver's arena.

    Key properties:
    - Single ownership: A token has exactly one owner at any time
    - Transfer semantics: Pushing to FIFO transfers ownership
    - Deep copy on wrap: Source value remains valid, token owns copy
    - Zero-copy unwrap: Token data moves into target arena

    This type ensures memory safety across actor boundaries by preventing
    aliasing of heap-allocated data through FIFOs.

    Example printed forms:
      !cal.token<i32>
      !cal.token<!cal.variant<"List", ...>>

    Operations:
      %tok = cal.token.wrap %val from %arena : T -> !cal.token<T>
      %val = cal.token.unwrap %tok into %arena : !cal.token<T> -> T
      cal.token.consume %tok : !cal.token<T>  // discard without unwrap
  }];
  let parameters = (ins "Type":$elementType);
  let assemblyFormat = "`<` $elementType `>`";
}

#endif // CAL_TYPES
