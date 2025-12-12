# Algebraic Types Support in CAL

This document describes the current state and planned implementation of algebraic types (sum types and product types) in the CAL language, including the proposed `cal.variant` MLIR dialect extension.

## Current Implementation Status

| Area | Status | Details |
|------|--------|---------|
| **Grammar/AST** | ✅ Complete | `AlgebraicTypeDecl`, `SumTypeDeclBody`, `ProductTypeDeclBody`, `VariantDecl`, `ExpressionConstructor`, `PatternDeconstruction` |
| **Type Checking** | ⚠️ Partial | Validators exist for arity, exhaustiveness, duplicate cases; missing Typir inference rule for `ExpressionConstructor` |
| **Code Generation** | ❌ Not Implemented | `lower-cal.ts` has TODO placeholders for all algebraic type expressions |

---

## 1. Grammar Support (Complete)

The CAL grammar fully supports algebraic type definitions:

```cal
namespace Example:

  // Sum type (tagged union) with variants
  type Maybe(type T):
    Some(T value)
  | None
  end

  // Product type (record/struct)
  type Vec2:
    (int x, int y)
  end

  // Sum type with multiple fields per variant
  type Result(type T, type E):
    Ok(T value)
  | Err(E error)
  end

end
```

### Constructor Expressions

```cal
// Sum type constructor
let m = Maybe::Some(42);
let n = Maybe::None;

// Product type constructor
let v = Vec2(10, 20);
```

### Pattern Matching

```cal
function unwrapOr(Maybe(type: int) m, int default) --> int:
  case m of
    Maybe::Some(v): v end
    Maybe::None: default end
  end
end
```

---

## 2. Type Checking Gaps

### 2.1 Missing Typir Inference Rule

**File**: `src/language/cal-type-module.ts`

The `ExpressionConstructor` AST node does not have a Typir inference rule that returns the algebraic type. This means while validation passes, the type system doesn't properly propagate the constructed type.

**Required Change**:

```typescript
// Add inference rule for ExpressionConstructor
// Should return the AlgebraicTypeDecl reference with bound type parameters
```

### 2.2 Existing Validators (Working)

The following validators in `src/language/cal-validator.ts` are implemented:

- Sum type constructor arity check (lines 1816-1820)
- Variant belongs to type check (lines 1808-1813)
- Pattern deconstruction arity (lines 1857-1888, 1933-1962)
- Exhaustiveness check for sum types (lines 1744-1779, 1892-1929)
- Exhaustiveness check for booleans (lines 1692-1742)
- Duplicate case detection (lines 1768-1771, 1919-1921)
- Generic type parameter consistency (lines 1620-1684)

---

## 3. Code Generation Gaps

### 3.1 Current State

In `src/cli/lower-cal.ts`, algebraic type expressions fall through to a default case:

```typescript
default: {
  const tmp = ctx.newTmp();
  ctx.push(`${tmp} = arith.constant 0 : i32 // TODO: lower ${tag}`);
  return { value: tmp, type: 'i32' };
}
```

### 3.2 Required Implementations

| AST Node | File | Action Needed |
|----------|------|---------------|
| `AlgebraicTypeDecl` | `src/cli/mlir/types.ts` | Add `!cal.variant` / `!cal.product` type mapping in `typeToMlir()` |
| `ExpressionConstructor` | `src/cli/mlir/lowering/expr-lowering.ts` | Emit `cal.variant.create` / `cal.product.create` operation |
| `PatternDeconstruction` | `src/cli/mlir/lowering/expr-lowering.ts` | Emit `cal.variant.get_tag` + `cal.variant.get_field` |
| `ExpressionCase` | `src/cli/mlir/lowering/expr-lowering.ts` | Emit tag switch with `scf.if` or `cal.variant.match` |
| `StatementCase` | `src/cli/mlir/emit/statements-core.ts` | Add case in `emitStatement()` for tag-based control flow |

---

## 4. Proposed CAL MLIR Dialect Extension: `cal.variant`

### 4.1 Design Rationale

We propose extending the CAL MLIR dialect with a first-class `!cal.variant` type and associated operations. This approach:

1. **Preserves semantics** at the MLIR level for high-level optimizations
2. **Enables pattern matching optimizations** before lowering to LLVM
3. **Supports generic instantiation** through type parameters
4. **Provides clean lowering path** to LLVM tagged unions

### 4.2 Type Definition

```mlir
// Variant type definition
// !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
// !cal.variant<"Result", [("Ok", [!cal.tensor<...>]), ("Err", [!cal.string])]>

// Syntax: !cal.variant<name, [(variant_name, [field_types...])]>
```

#### Type Representation in TableGen

```tablegen
def Cal_VariantType : Cal_Type<"Variant", "variant"> {
  let summary = "Algebraic sum type (tagged union)";
  let description = [{
    Represents a sum type with named variants, each containing zero or more fields.
    
    Example:
      !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
  }];
  
  let parameters = (ins
    StringRefParameter<"type name">:$name,
    ArrayRefParameter<"variant descriptors">:$variants
  );
  
  let assemblyFormat = "`<` $name `,` $variants `>`";
}

def Cal_ProductType : Cal_Type<"Product", "product"> {
  let summary = "Algebraic product type (record/struct)";
  let description = [{
    Represents a product type with named fields.
    
    Example:
      !cal.product<"Vec2", [("x", i32), ("y", i32)]>
  }];
  
  let parameters = (ins
    StringRefParameter<"type name">:$name,
    ArrayRefParameter<"field descriptors">:$fields
  );
  
  let assemblyFormat = "`<` $name `,` $fields `>`";
}
```

### 4.3 Operations

#### 4.3.1 `cal.variant.create` — Construct a Variant

```mlir
// Create a Some(42) value
%value = arith.constant 42 : i32
%some = cal.variant.create "Some"(%value) : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>

// Create a None value
%none = cal.variant.create "None"() : !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
```

**TableGen Definition**:

```tablegen
def Cal_VariantCreateOp : Cal_Op<"variant.create", [Pure]> {
  let summary = "Create a variant value";
  let description = [{
    Constructs a variant value with the specified variant name and field values.
  }];
  
  let arguments = (ins
    StrAttr:$variant_name,
    Variadic<AnyType>:$fields
  );
  
  let results = (outs Cal_VariantType:$result);
  
  let assemblyFormat = [{
    $variant_name `(` $fields `)` attr-dict `:` type($result)
  }];
}
```

#### 4.3.2 `cal.variant.get_tag` — Extract Discriminant Tag

```mlir
// Get the tag index (0 for Some, 1 for None)
%tag = cal.variant.get_tag %maybe : !cal.variant<"Maybe", ...> -> index
```

**TableGen Definition**:

```tablegen
def Cal_VariantGetTagOp : Cal_Op<"variant.get_tag", [Pure]> {
  let summary = "Get variant discriminant tag";
  let description = [{
    Returns the index of the active variant (0-based).
  }];
  
  let arguments = (ins Cal_VariantType:$variant);
  let results = (outs Index:$tag);
  
  let assemblyFormat = [{
    $variant attr-dict `:` type($variant) `->` type($tag)
  }];
}
```

#### 4.3.3 `cal.variant.get_field` — Extract Field Value

```mlir
// Extract field 0 from Some variant (assumes tag is correct)
%value = cal.variant.get_field %maybe["Some", 0] : !cal.variant<"Maybe", ...> -> i32
```

**TableGen Definition**:

```tablegen
def Cal_VariantGetFieldOp : Cal_Op<"variant.get_field", [Pure]> {
  let summary = "Extract a field from a variant";
  let description = [{
    Extracts a field value from a variant. The variant must be the specified
    variant name (undefined behavior otherwise).
  }];
  
  let arguments = (ins
    Cal_VariantType:$variant,
    StrAttr:$variant_name,
    I64Attr:$field_index
  );
  
  let results = (outs AnyType:$result);
  
  let assemblyFormat = [{
    $variant `[` $variant_name `,` $field_index `]` attr-dict 
    `:` type($variant) `->` type($result)
  }];
}
```

#### 4.3.4 `cal.variant.match` — Pattern Match (Optional High-Level Op)

```mlir
// High-level match operation (lowers to scf.if chain or llvm.switch)
%result = cal.variant.match %maybe : !cal.variant<"Maybe", ...> -> i32 {
  ^Some(%v: i32):
    cal.variant.yield %v : i32
  ^None:
    %zero = arith.constant 0 : i32
    cal.variant.yield %zero : i32
}
```

**TableGen Definition**:

```tablegen
def Cal_VariantMatchOp : Cal_Op<"variant.match", [
    SingleBlockImplicitTerminator<"VariantYieldOp">,
    RecursiveMemoryEffects
  ]> {
  let summary = "Pattern match on a variant";
  let description = [{
    Structured pattern matching operation. Each region corresponds to a variant
    case and receives the variant's fields as block arguments.
  }];
  
  let arguments = (ins Cal_VariantType:$variant);
  let results = (outs AnyType:$result);
  let regions = (region VariadicRegion<SizedRegion<1>>:$cases);
  
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}

def Cal_VariantYieldOp : Cal_Op<"variant.yield", [
    Pure, ReturnLike, Terminator,
    ParentOneOf<["VariantMatchOp"]>
  ]> {
  let summary = "Yield result from variant match case";
  let arguments = (ins AnyType:$result);
  let assemblyFormat = "$result attr-dict `:` type($result)";
}
```

#### 4.3.5 `cal.product.create` — Construct a Product Type

```mlir
%x = arith.constant 10 : i32
%y = arith.constant 20 : i32
%vec = cal.product.create(%x, %y) : !cal.product<"Vec2", [("x", i32), ("y", i32)]>
```

#### 4.3.6 `cal.product.get_field` — Extract Product Field

```mlir
%x_val = cal.product.get_field %vec["x"] : !cal.product<"Vec2", ...> -> i32
```

### 4.4 Memory Layout (For LLVM Lowering)

The `!cal.variant` type lowers to an LLVM struct with:

1. **Tag field**: `i32` discriminant (variant index)
2. **Payload field**: Union of all variant payloads (size = max variant size)

```mlir
// !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
// Lowers to:
!llvm.struct<(i32, array<4 x i8>)>  // tag + 4-byte payload (size of i32)

// !cal.variant<"Result", [("Ok", [i64, i64]), ("Err", [i32])]>
// Lowers to:
!llvm.struct<(i32, array<16 x i8>)>  // tag + 16-byte payload (size of 2×i64)
```

### 4.5 Lowering Passes

#### Pass 1: `cal-variant-to-scf`

Lowers `cal.variant.match` to `scf.if` chains:

```mlir
// Before:
%result = cal.variant.match %maybe -> i32 {
  ^Some(%v: i32): cal.variant.yield %v
  ^None: cal.variant.yield %c0
}

// After:
%tag = cal.variant.get_tag %maybe
%is_some = arith.cmpi eq, %tag, %c0_index
%result = scf.if %is_some -> i32 {
  %v = cal.variant.get_field %maybe["Some", 0] : ... -> i32
  scf.yield %v : i32
} else {
  scf.yield %c0 : i32
}
```

#### Pass 2: `cal-variant-to-llvm`

Lowers `!cal.variant` types and operations to LLVM:

```mlir
// cal.variant.create "Some"(%value)
// Becomes:
%struct = llvm.mlir.undef : !llvm.struct<(i32, array<4 x i8>)>
%with_tag = llvm.insertvalue %c0_i32, %struct[0]
%payload_ptr = llvm.getelementptr %with_tag[1] : ...
llvm.store %value, %payload_ptr

// cal.variant.get_tag %v
// Becomes:
%tag = llvm.extractvalue %v[0] : !llvm.struct<...>

// cal.variant.get_field %v["Some", 0]
// Becomes:
%payload_ptr = llvm.getelementptr %v[1] : ...
%field_ptr = llvm.bitcast %payload_ptr to !llvm.ptr<i32>
%value = llvm.load %field_ptr
```

---

## 5. Implementation Plan

### Phase 1: Type System Completion

- [x] Add Typir inference rule for `ExpressionConstructor`
- [x] Ensure type propagation through `case` expressions (added algebraic type support to `unifyTypes`)
- [x] Add tests for type inference

### Phase 2: MLIR Dialect Extension ✅

- [x] Define `!cal.variant` type in CAL dialect (TableGen + C++)
- [x] Define `!cal.product` type in CAL dialect
- [x] Implement `cal.variant.create` operation
- [x] Implement `cal.variant.get_tag` operation
- [x] Implement `cal.variant.get_field` operation
- [x] Implement `cal.product.create` operation
- [x] Implement `cal.product.get_field` operation
- [x] Implement `cal.variant.match` high-level operation
- [x] Implement `cal.variant.yield` terminator for match cases
- [x] Add verifiers for all operations (type checking, field bounds, etc.)
- [x] Add tests for parsing/printing and verification

### Phase 3: Code Generation ✅

- [x] Emit `!cal.variant` type definitions for `AlgebraicTypeDecl`
- [x] Lower `ExpressionConstructor` to `cal.variant.create` / `cal.product.create`
- [x] Lower `PatternDeconstruction` to `cal.variant.get_tag` + `cal.variant.get_field`
- [x] Lower `ExpressionCase` to `scf.if` chain with tag checks
- [x] Lower `StatementCase` to control flow with tag checks

### Phase 4: LLVM Lowering Pass (Requires Careful Design)

The current Phase 4 design is **too simplistic** and does not handle important cases:

#### 4.1 Simple (Non-Recursive) Types — Current Design Works

- [ ] Implement `cal-variant-to-llvm` pass for fixed-size variants
- [ ] Define inline memory layout for variant types (tag + payload union)
- [ ] Handle alignment and padding correctly
- [ ] Test with various payload sizes

#### 4.2 Recursive Types — **Major Design Decision Required**

Recursive types like `List<T>` cannot use inline storage:

```cal
type List(type T):
  Cons(T head, List(type: T) tail)
| Nil
end
```

**Problem**: The `Cons` variant contains a `List` field, creating infinite size if inlined.

**Solutions** (need to pick one):

##### Option A: Automatic Boxing (Rust-like)

Automatically box recursive type references using heap allocation:

```mlir
// !cal.variant<"List", [("Cons", [i32, !cal.variant<"List", ...>]), ("Nil", [])]>
// Lowers to:
!llvm.struct<(i32, ptr)>  // tag + pointer to boxed payload

// Cons variant payload becomes heap-allocated
// Requires runtime: malloc/free or reference counting
```

**Pros**: Transparent to user, matches Rust/Haskell semantics
**Cons**: Requires memory management (GC, RC, or manual)

##### Option B: Explicit Box Type

Require users to explicitly box recursive references:

```cal
type List(type T):
  Cons(T head, Box(List(type: T)) tail)  // User must add Box
| Nil
end
```

**Pros**: Memory allocation is explicit, user controls heap usage
**Cons**: More verbose, breaks traditional ADT ergonomics

##### Option C: Arena/Region-Based Allocation

Allocate all variants from a per-actor or per-network arena:

```mlir
// Create arena at network/actor scope
%arena = cal.arena.create : !cal.arena

// Variant creation specifies arena
%cons = cal.variant.create "Cons"(%head, %tail) in %arena 
        : !cal.variant<"List", ...>

// Arena freed when actor/network terminates
cal.arena.destroy %arena
```

**Pros**: Batch deallocation, good for dataflow (actors have clear lifetimes)
**Cons**: More complex API, arena lifetime management

##### Option D: Dataflow-Specific Design ✅ CHOSEN

Since CAL is for dataflow actors, we leverage its unique characteristics:

1. **Token-based ownership**: Variants passed through FIFOs transfer ownership
2. **Actor-scoped allocation**: Memory allocated by an actor is freed when actor terminates
3. **Action-scoped arenas**: Temporary allocations freed at action end
4. **Reference counting for shared state**: Only for state variables, not tokens

---

## 4.3 Chosen Design: Dataflow-Aware Memory Management

### 4.3.1 Core Principles

| Principle | Description |
|-----------|-------------|
| **Actors are isolated** | No shared memory between actors; FIFOs are the only communication channel |
| **Tokens have single owner** | Data flowing through FIFOs has exactly one owner at any time |
| **Actions are bounded** | Each action firing has a clear start and end for allocation scoping |
| **State persists** | Actor state variables live across firings, need different treatment |

### 4.3.2 Three Allocation Contexts

We introduce three distinct allocation contexts, each with appropriate lifetime semantics:

#### Context 1: Action-Local Arena

For temporary allocations within a single action firing:

```mlir
// Implicitly created at action start
%arena = cal.arena.create : !cal.arena

// All recursive variant allocations go here
%cons = cal.variant.create "Cons"(%head, %tail) in %arena 
        : !cal.variant<"List", ...>

// Implicitly destroyed at action end
cal.arena.destroy %arena
```

**Properties:**
- Bump-pointer allocation (very fast)
- Single deallocation (no per-object overhead)  
- Cannot escape action scope without explicit transfer

#### Context 2: Reference-Counted State

For state variables that persist across action firings:

```mlir
// State allocation with reference counting
%state_list = cal.rc.alloc %value : !cal.rc<!cal.variant<"List", ...>>

// Increment refcount on copy
%copy = cal.rc.retain %state_list : !cal.rc<!cal.variant<"List", ...>>

// Decrement refcount (free if zero)
cal.rc.release %old_state : !cal.rc<!cal.variant<"List", ...>>
```

**Properties:**
- Deterministic deallocation
- Handles state variable updates correctly
- Warn on potentially unbounded growth

#### Context 3: FIFO Token Transfer

For data passing through FIFO channels:

```mlir
// Wrap arena value for FIFO transfer (deep copy out of arena)
%token = cal.token.wrap %arena_value from %arena 
         : !cal.variant<"List", ...> -> !cal.token<!cal.variant<"List", ...>>

// Push transfers ownership
fifo.push(%out, %token)  // %token invalidated after this

// Pop receives ownership
%received = fifo.pop(%in) : !cal.token<!cal.variant<"List", ...>>

// Unwrap into receiver's arena
%local = cal.token.unwrap %received into %my_arena
         : !cal.token<!cal.variant<"List", ...>> -> !cal.variant<"List", ...>
```

**Properties:**
- Single ownership (no aliasing through FIFOs)
- Deep copy on wrap (arena value → token)
- Zero-copy on unwrap (token → arena value)
- FIFO buffer owns tokens until popped

### 4.3.3 Memory Layout

#### Non-Recursive Types (Inline)

```
┌─────────────────────────────────────┐
│ Variant (inline storage)            │
├─────────────────────────────────────┤
│ tag: i32                            │
│ payload: [max_variant_size bytes]   │
└─────────────────────────────────────┘
```

#### Recursive Types (Boxed)

```
┌─────────────────────────────────────┐
│ Variant (with boxed field)          │
├─────────────────────────────────────┤
│ tag: i32                            │
│ field_0: T (inline)                 │
│ field_1: ptr → [recursive variant]  │
└─────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────┐
│ Boxed Variant (in arena/heap)       │
├─────────────────────────────────────┤
│ [header: arena_id or refcount]      │
│ tag: i32                            │
│ fields...                           │
└─────────────────────────────────────┘
```

#### Token Wrapper

```
┌─────────────────────────────────────┐
│ Token                               │
├─────────────────────────────────────┤
│ ownership_tag: i8 (owned/consumed)  │
│ data_ptr: ptr → [deep-copied data]  │
│ size: i64 (for deallocation)        │
└─────────────────────────────────────┘
```

### 4.3.4 FIFO Semantics

#### Push Behavior

```cal
actor Producer() ports_out(output: List(type: int)):
  action:
    let myList = List::Cons(1, List::Cons(2, List::Nil));
    // myList is in action-local arena
    
    fifo.push(output, myList);
    // Deep copy from arena → token → FIFO buffer
    // myList still valid in this action (arena not freed yet)
    // But logically, the token now owns the data
    
    // At action end: arena freed, myList gone
  end
end
```

#### Pop Behavior

```cal
actor Consumer() ports_in(input: List(type: int)):
  action:
    let received = fifo.pop(input);
    // Token unwrapped into this action's arena
    // received is now a local arena allocation
    
    // Process received...
    
    // At action end: arena freed, received gone
  end
end
```

#### State Variable Assignment

```cal
actor Accumulator() ports_in(input: int):
  state accum: List(type: int) := List::Nil
  
  action:
    let item = fifo.pop(input);
    let newAccum = List::Cons(item, accum);
    // newAccum in action arena, references RC state
    
    accum := newAccum;
    // 1. Deep copy newAccum to RC allocation
    // 2. Release old accum (decrement refcount)
    // 3. Update state reference
  end
end
```

---

## 4.4 New Types and Operations

### 4.4.1 Arena Type and Operations

```tablegen
//===----------------------------------------------------------------------===//
// Arena Type
//===----------------------------------------------------------------------===//

def Cal_ArenaType : Cal_Type<"Arena", "arena"> {
  let summary = "Action-scoped memory arena for temporary allocations";
  let description = [{
    Represents a bump-pointer arena for fast allocation of temporary values.
    Arenas are created at action start and destroyed at action end.
  }];
}

//===----------------------------------------------------------------------===//
// Arena Operations
//===----------------------------------------------------------------------===//

def Cal_ArenaCreateOp : Cal_Op<"arena.create", [MemoryEffects<[MemAlloc]>]> {
  let summary = "Create a new memory arena";
  let arguments = (ins OptionalAttr<I64Attr>:$initial_size);
  let results = (outs Cal_Arena:$arena);
  let assemblyFormat = "(`size` `(` $initial_size^ `)`)? attr-dict `:` type($arena)";
}

def Cal_ArenaDestroyOp : Cal_Op<"arena.destroy", [MemoryEffects<[MemFree]>]> {
  let summary = "Destroy arena and free all allocations";
  let arguments = (ins Cal_Arena:$arena);
  let assemblyFormat = "$arena attr-dict `:` type($arena)";
}

def Cal_ArenaAllocOp : Cal_Op<"arena.alloc", [MemoryEffects<[MemAlloc]>]> {
  let summary = "Allocate memory from arena";
  let arguments = (ins Cal_Arena:$arena, Index:$size, Index:$alignment);
  let results = (outs LLVM_AnyPointer:$ptr);
  let assemblyFormat = "$arena `[` $size `,` `align` $alignment `]` attr-dict `:` type($ptr)";
}
```

### 4.4.2 Reference-Counted Type and Operations

```tablegen
//===----------------------------------------------------------------------===//
// RC (Reference Counted) Type  
//===----------------------------------------------------------------------===//

def Cal_RCType : Cal_Type<"RC", "rc"> {
  let summary = "Reference-counted heap allocation";
  let description = [{
    Wraps a value with reference counting for state variables that persist
    across action firings.
  }];
  let parameters = (ins "Type":$elementType);
  let assemblyFormat = "`<` $elementType `>`";
}

//===----------------------------------------------------------------------===//
// RC Operations
//===----------------------------------------------------------------------===//

def Cal_RCAllocOp : Cal_Op<"rc.alloc", [MemoryEffects<[MemAlloc]>]> {
  let summary = "Allocate reference-counted value (refcount = 1)";
  let arguments = (ins AnyType:$value);
  let results = (outs Cal_RC:$result);
  let assemblyFormat = "$value attr-dict `:` type($value) `->` type($result)";
}

def Cal_RCRetainOp : Cal_Op<"rc.retain", [MemoryEffects<[MemRead, MemWrite]>]> {
  let summary = "Increment reference count";
  let arguments = (ins Cal_RC:$value);
  let results = (outs Cal_RC:$result);
  let assemblyFormat = "$value attr-dict `:` type($value)";
}

def Cal_RCReleaseOp : Cal_Op<"rc.release", [MemoryEffects<[MemRead, MemWrite, MemFree]>]> {
  let summary = "Decrement reference count (free if zero)";
  let arguments = (ins Cal_RC:$value);
  let assemblyFormat = "$value attr-dict `:` type($value)";
}

def Cal_RCLoadOp : Cal_Op<"rc.load", [MemoryEffects<[MemRead]>]> {
  let summary = "Load value from RC container";
  let arguments = (ins Cal_RC:$rc);
  let results = (outs AnyType:$value);
  let assemblyFormat = "$rc attr-dict `:` type($rc) `->` type($value)";
}
```

### 4.4.3 Token Type and Operations

```tablegen
//===----------------------------------------------------------------------===//
// Token Type (for FIFO transfer)
//===----------------------------------------------------------------------===//

def Cal_TokenType : Cal_Type<"Token", "token"> {
  let summary = "Owned data token for FIFO transfer";
  let description = [{
    Represents data being transferred through a FIFO with single ownership.
    Created by wrapping arena/RC values, consumed by unwrapping.
  }];
  let parameters = (ins "Type":$elementType);
  let assemblyFormat = "`<` $elementType `>`";
}

//===----------------------------------------------------------------------===//
// Token Operations
//===----------------------------------------------------------------------===//

def Cal_TokenWrapOp : Cal_Op<"token.wrap", [MemoryEffects<[MemAlloc, MemRead]>]> {
  let summary = "Wrap a value into a token (deep copy)";
  let description = [{
    Creates a token by deep-copying the value. The source value remains valid
    but the token now owns an independent copy.
  }];
  let arguments = (ins AnyType:$value, Optional<Cal_Arena>:$source_arena);
  let results = (outs Cal_Token:$token);
  let assemblyFormat = "$value (`from` $source_arena^)? attr-dict `:` type($value) `->` type($token)";
}

def Cal_TokenUnwrapOp : Cal_Op<"token.unwrap", [MemoryEffects<[MemRead, MemFree]>]> {
  let summary = "Unwrap a token into target arena (consumes token)";
  let description = [{
    Extracts the value from a token into the target arena. The token is
    consumed and cannot be used again.
  }];
  let arguments = (ins Cal_Token:$token, Cal_Arena:$target_arena);
  let results = (outs AnyType:$value);
  let assemblyFormat = "$token `into` $target_arena attr-dict `:` type($token) `->` type($value)";
}

def Cal_TokenConsumeOp : Cal_Op<"token.consume", [MemoryEffects<[MemFree]>]> {
  let summary = "Consume token without unwrapping (discard)";
  let arguments = (ins Cal_Token:$token);
  let assemblyFormat = "$token attr-dict `:` type($token)";
}
```

### 4.4.4 Boxed Variant Operations

```tablegen
//===----------------------------------------------------------------------===//
// Boxing Operations (for recursive type fields)
//===----------------------------------------------------------------------===//

def Cal_BoxInArenaOp : Cal_Op<"box.in_arena", [MemoryEffects<[MemAlloc, MemWrite]>]> {
  let summary = "Box a value in an arena (for recursive fields)";
  let arguments = (ins AnyType:$value, Cal_Arena:$arena);
  let results = (outs LLVM_AnyPointer:$boxed);
  let assemblyFormat = "$value `in` $arena attr-dict `:` type($value) `->` type($boxed)";
}

def Cal_UnboxOp : Cal_Op<"unbox", [MemoryEffects<[MemRead]>]> {
  let summary = "Unbox a pointer to get the value";
  let arguments = (ins LLVM_AnyPointer:$boxed);
  let results = (outs AnyType:$value);
  let assemblyFormat = "$boxed attr-dict `:` type($boxed) `->` type($value)";
}
```

---

## 4.5 Lowering Pipeline

### 4.5.1 Pass: `cal-detect-recursive-types`

Analyzes variant types and marks recursive fields:

```mlir
// Input:
!cal.variant<"List", [("Cons", [i32, !cal.variant<"List", ...>]), ("Nil", [])]>

// Output (with attribute):
!cal.variant<"List", [("Cons", [i32, !cal.variant<"List", ...>]), ("Nil", [])]>
    {recursive_fields = [["Cons", 1]]}  // Cons field index 1 is recursive
```

### 4.5.2 Pass: `cal-insert-arenas`

Inserts arena creation/destruction in actions:

```mlir
// Input:
cal.action {
  %list = cal.variant.create "Cons"(%head, %tail) : !list_type
  fifo.push(%out, %list)
}

// Output:
cal.action {
  %arena = cal.arena.create : !cal.arena
  %list = cal.variant.create "Cons"(%head, %tail) in %arena : !list_type
  %token = cal.token.wrap %list from %arena : !list_type -> !cal.token<!list_type>
  fifo.push(%out, %token)
  cal.arena.destroy %arena
}
```

### 4.5.3 Pass: `cal-insert-rc-for-state`

Wraps state variable accesses with RC operations:

```mlir
// Input:
%old = cal.get(%state_ref) : !list_type
%new = cal.variant.create "Cons"(%x, %old) : !list_type
cal.set(%state_ref, %new)

// Output:
%old_rc = cal.get(%state_ref) : !cal.rc<!list_type>
%old = cal.rc.load %old_rc : !cal.rc<!list_type> -> !list_type
%new = cal.variant.create "Cons"(%x, %old) in %arena : !list_type
%new_rc = cal.rc.alloc %new : !list_type -> !cal.rc<!list_type>
cal.rc.release %old_rc : !cal.rc<!list_type>
cal.set(%state_ref, %new_rc)
```

### 4.5.4 Pass: `cal-variant-to-llvm`

Lowers variant types and operations to LLVM:

```mlir
// Inline variant → LLVM struct
!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>
  → !llvm.struct<(i32, array<4 x i8>)>

// Recursive variant field → pointer
!cal.variant<"List", [("Cons", [i32, !cal.variant<"List", ...>]), ("Nil", [])]>
  → !llvm.struct<(i32, i32, ptr)>  // tag, head, tail_ptr

// Arena → opaque pointer with runtime support
!cal.arena → !llvm.ptr

// RC → struct with refcount
!cal.rc<T> → !llvm.struct<(i32, T)>  // refcount + value

// Token → struct with ownership flag
!cal.token<T> → !llvm.struct<(i8, ptr, i64)>  // flag, data, size
```

---

## 4.6 Runtime Support Functions

The following runtime functions must be provided (in C or generated LLVM):

```c
// Arena management
void* cal_arena_create(size_t initial_size);
void  cal_arena_destroy(void* arena);
void* cal_arena_alloc(void* arena, size_t size, size_t align);

// Reference counting
void* cal_rc_alloc(size_t size);
void  cal_rc_retain(void* ptr);
void  cal_rc_release(void* ptr, void (*destructor)(void*));

// Token management  
void* cal_token_create(size_t size);
void  cal_token_destroy(void* token);

// Deep copy support (generated per-type)
void* cal_variant_deep_copy_List(void* src, void* dst_arena);
```

---

## 4.7 Implementation Tasks

### Phase 4.1: Infrastructure ✅ COMPLETE

- [x] Add `!cal.arena` type to CalTypes.td
- [x] Add `!cal.rc<T>` type to CalTypes.td  
- [x] Add `!cal.token<T>` type to CalTypes.td
- [x] Implement arena operations in CalOps.td (`cal.arena.create`, `cal.arena.destroy`, `cal.arena.alloc`)
- [x] Implement RC operations in CalOps.td (`cal.rc.alloc`, `cal.rc.retain`, `cal.rc.release`, `cal.rc.load`, `cal.rc.store`)
- [x] Implement token operations in CalOps.td (`cal.token.wrap`, `cal.token.unwrap`, `cal.token.consume`)
- [x] Implement boxing operations in CalOps.td (`cal.box.in_arena`, `cal.unbox`)
- [x] Implement deep copy operation in CalOps.td (`cal.deep_copy`)
- [x] Add type definitions in CalTypes.cpp
- [x] Add operation verifiers in CalOps.cpp
- [x] Add tests for new types and operations (`test/Dialect/Cal/memory-management-ops.mlir`)

### Phase 4.2: Recursive Type Detection

- [ ] Implement `cal-detect-recursive-types` analysis pass
- [ ] Add recursive field marking attributes
- [ ] Test with List, Tree, and other recursive types

### Phase 4.3: Arena Insertion

- [ ] Implement `cal-insert-arenas` transformation pass
- [ ] Modify `cal.variant.create` to accept arena operand
- [ ] Add token wrap/unwrap around FIFO operations
- [ ] Test arena scoping correctness

### Phase 4.4: State Variable RC

- [ ] Implement `cal-insert-rc-for-state` transformation pass
- [ ] Handle state variable initialization
- [ ] Handle state variable updates with proper retain/release
- [ ] Test reference counting correctness

### Phase 4.5: LLVM Lowering

- [ ] Implement `cal-variant-to-llvm` conversion pass
- [ ] Generate memory layouts for variants
- [ ] Lower arena ops to runtime calls
- [ ] Lower RC ops to inline refcount manipulation
- [ ] Lower token ops to runtime calls
- [ ] Generate per-type deep copy functions

### Phase 4.6: Runtime Library

- [ ] Implement arena allocator in C
- [ ] Implement RC infrastructure in C
- [ ] Implement token management in C
- [ ] Link runtime with generated code
- [ ] Test with valgrind/asan for memory safety

### Phase 5: Testing & Documentation

- [ ] Add MLIR output tests for algebraic types
- [ ] Add end-to-end execution tests
- [ ] Document usage in CAL language guide

---

## 6. Example: Full Pipeline

### CAL Source

```cal
namespace Example:

  type Maybe(type T):
    Some(T value)
  | None
  end

  function unwrapOr(Maybe(type: int) m, int default) --> int:
    case m of
      Maybe::Some(v): v end
      Maybe::None: default end
    end
  end

end
```

### Generated MLIR (After Phase 3)

```mlir
module {
  // Type alias for readability
  !maybe_int = !cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>

  func.func @Example_unwrapOr(%m: !maybe_int, %default: i32) -> i32 {
    %tag = cal.variant.get_tag %m : !maybe_int -> index
    %c0 = arith.constant 0 : index
    %is_some = arith.cmpi eq, %tag, %c0 : index
    %result = scf.if %is_some -> i32 {
      %v = cal.variant.get_field %m["Some", 0] : !maybe_int -> i32
      scf.yield %v : i32
    } else {
      scf.yield %default : i32
    }
    return %result : i32
  }
}
```

### Generated LLVM IR (After Phase 4)

```mlir
module {
  !maybe_int_llvm = !llvm.struct<(i32, array<4 x i8>)>

  llvm.func @Example_unwrapOr(%m: !maybe_int_llvm, %default: i32) -> i32 {
    %tag = llvm.extractvalue %m[0] : !maybe_int_llvm
    %c0 = llvm.mlir.constant(0 : i32) : i32
    %is_some = llvm.icmp "eq" %tag, %c0 : i32
    llvm.cond_br %is_some, ^some, ^none
  ^some:
    %payload_ptr = llvm.getelementptr %m[1] : ...
    %value_ptr = llvm.bitcast %payload_ptr : !llvm.ptr<array<4 x i8>> to !llvm.ptr<i32>
    %v = llvm.load %value_ptr : !llvm.ptr<i32>
    llvm.br ^merge(%v : i32)
  ^none:
    llvm.br ^merge(%default : i32)
  ^merge(%result: i32):
    llvm.return %result : i32
  }
}
```

---

## 7. References

- [MLIR Dialect Definition](https://mlir.llvm.org/docs/DefiningDialects/)
- [MLIR Type System](https://mlir.llvm.org/docs/DefiningDialects/AttributesAndTypes/)
- [Rust Enum Layout](https://doc.rust-lang.org/reference/type-layout.html#reprc-enums-with-fields)
- [Swift Enum Implementation](https://github.com/apple/swift/blob/main/docs/ABI/TypeLayout.rst)
