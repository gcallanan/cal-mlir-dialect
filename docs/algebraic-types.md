# Algebraic Types Support in CAL

This document describes the current state and planned implementation of algebraic types (sum types and product types) in the CAL language, including the proposed `cal.variant` MLIR dialect extension.

## Quick Status: What's Next?

**Completed (end-to-end algebraic type support):**

1. ✅ **Variant/Product → LLVM Lowering** — Lower `!cal.variant` and `!cal.product` to LLVM structs
   - Implemented memory layout: `{ i32 tag, [max_payload_size x i8] payload }` for variants
   - Lowered `cal.variant.create`, `cal.variant.get_tag`, `cal.variant.get_field`
   - Lowered `cal.product.create`, `cal.product.get_field`
   - Location: `lib/Conversion/CalVariantToLLVM/`

2. ✅ **Type-aware Size Calculation** — Fixed hardcoded sizes in memory ops
   - `cal.rc.alloc`: computes actual `sizeof(T)` using DataLayout
   - `cal.token.wrap`: computes actual `sizeof(T)` 
   - `cal.box.in_arena`: computes actual `sizeof(T)` and proper alignment
   - Location: `lib/Conversion/CalMemoryToLLVM/CalMemoryToLLVM.cpp`

3. ✅ **cal.deep_copy Implementation** — Implemented arena-based deep copy
   - Allocates space in target arena and copies value
   - Handles variant and product types via LLVM struct copy
   - Location: `lib/Conversion/CalMemoryToLLVM/CalMemoryToLLVM.cpp`

4. ✅ **Pipeline Integration** — CalVariantToLLVM and CalMemoryToLLVM integrated
   - Both passes added to `--lower-cal-to-llvm` pipeline
   - CalVariantToLLVM runs before CalMemoryToLLVM
   - Location: `lib/Conversion/CalLoweringPipelines/CalLoweringPipelines.cpp`

5. ✅ **Arena Bounds Checking** — Prevent overflow in arena allocations
   - `cal.arena.alloc`, `cal.box.in_arena`, `cal.deep_copy` now check capacity
   - Calls `abort()` if allocation would exceed arena capacity
   - Location: `lib/Conversion/CalMemoryToLLVM/CalMemoryToLLVM.cpp`

6. ✅ **RC Release for Recursive Types** — Complete with runtime verification
   - Generates type-specific `__cal_release_<TypeName>` functions
   - Handles self-recursive types (e.g., linked lists, binary trees)
   - Mutual recursion infrastructure in place via `cal.pointer_field_types` module attribute
   - Runtime verified: linked list chains correctly freed via lli
   - Location: `lib/Conversion/CalMemoryToLLVM/CalMemoryToLLVM.cpp`

7. ✅ **Boxing Transformation Passes** — Analysis and transformation passes implemented
   - `cal-detect-recursive-types`: Marks variant/product types with `cal.recursive_type` attribute
   - `cal-insert-arenas`: Inserts `cal.arena.create`/`cal.arena.destroy` around execution bodies
   - `cal-insert-rc-for-state`: Marks state variable ops with RC attributes (`cal.rc_managed`, etc.)
   - `cal-materialize-rc-ops`: Transforms marked ops into actual RC operations:
     - State type: `!cal.state_ref<T>` → `!cal.state_ref<!cal.rc<T>>`
     - Inserts `cal.rc.load` after `cal.get`
     - Inserts `cal.rc.release` + `cal.rc.alloc` around `cal.set`
   - Location: `lib/Dialect/Cal/CalPassesDetect*.cpp`, `CalPassesInsert*.cpp`, `CalPassesMaterialize*.cpp`

8. ✅ **Mutual Recursion Support** — Infrastructure for mutually recursive types
   - `cal-detect-recursive-types` populates `cal.pointer_field_types` module attribute
   - `CalMemoryToLLVM` uses attribute to dispatch correct release functions per field
   - Self-recursion fallback when annotation not present
   - Location: `lib/Dialect/Cal/CalPassesDetectRecursiveTypes.cpp`, `lib/Conversion/CalMemoryToLLVM/`

**Remaining Work:**

- **Frontend Codegen** — Emit `cal.variant.*` and `cal.product.*` ops from CAL frontend
- **Recursive Deep Copy** — Handle truly recursive types by following boxed pointers in `cal.deep_copy`
- **cal.variant.match Lowering** — Lower high-level match operation to scf.if chains

**See Section 6 for full remaining work breakdown.**

---

## Current Implementation Status

| Area | Status | Details |
|------|--------|---------|
| **Grammar/AST** | ✅ Complete | `AlgebraicTypeDecl`, `SumTypeDeclBody`, `ProductTypeDeclBody`, `VariantDecl`, `ExpressionConstructor`, `PatternDeconstruction` |
| **Type Checking** | ⚠️ Partial | Validators exist for arity, exhaustiveness, duplicate cases; missing Typir inference rule for `ExpressionConstructor` |
| **Code Generation** | ❌ Not Implemented | `lower-cal.ts` has TODO placeholders for all algebraic type expressions |
| **Boxing Passes** | ✅ Complete | `cal-detect-recursive-types`, `cal-insert-arenas`, `cal-insert-rc-for-state`, `cal-materialize-rc-ops` |

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

#### 4.1 Simple (Non-Recursive) Types — ✅ Complete

- [x] Implement `cal-variant-to-llvm` pass for fixed-size variants
- [x] Define inline memory layout for variant types (tag + payload union)
- [x] Handle alignment and padding correctly
- [x] Test with various payload sizes

**Implementation:** The `CalVariantToLLVM` pass in `lib/Conversion/CalVariantToLLVM/` implements:
- `VariantCreateOpLowering` - Creates LLVM struct with tag + payload
- `VariantGetTagOpLowering` - Extracts tag from struct
- `VariantGetFieldOpLowering` - Extracts field from payload via GEP+bitcast
- `ProductCreateOpLowering` - Creates LLVM struct with fields
- `ProductGetFieldOpLowering` - Extracts field from product struct

**Note:** `cal.variant.match` lowering is not yet implemented (high-level pattern matching should be 
lowered to `scf.if` chains before this pass runs).

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

// Arena → opaque pointer (managed inline)
!cal.arena → !llvm.ptr

// RC → struct with refcount
!cal.rc<T> → !llvm.struct<(i32, T)>  // refcount + value

// Token → struct with ownership flag
!cal.token<T> → !llvm.struct<(i8, ptr, i64)>  // flag, data, size
```

---

## 4.6 Inline LLVM Code Generation

All memory management operations are generated as **inline LLVM code** - no external C runtime is required. This approach provides:

1. **Better optimization opportunities** - LLVM can inline and optimize memory operations
2. **No external dependencies** - Self-contained executables without runtime library linking
3. **Type-specific code generation** - Release functions are generated per-type for recursive types

### Generated Inline Operations

| CAL Operation | Generated LLVM |
|--------------|----------------|
| `cal.arena.create` | `llvm.call @malloc` + initialize header struct |
| `cal.arena.destroy` | `llvm.call @free` |
| `cal.arena.alloc` | Bump pointer arithmetic + alignment |
| `cal.rc.alloc` | `llvm.call @malloc` + initialize refcount to 1 |
| `cal.rc.retain` | `llvm.atomicrmw add` on refcount |
| `cal.rc.release` | `llvm.atomicrmw sub` + conditional `llvm.call @free` |
| `cal.token.wrap` | Deep copy into token buffer |
| `cal.token.unwrap` | Transfer ownership to arena |

### Type-Specific Release Functions

For recursive types (e.g., `List`, `Tree`), the `CalMemoryToLLVM` pass generates specialized release functions:

```llvm
// Generated for !cal.variant<"List", [("Cons", [i32, !llvm.ptr]), ("Nil", [])]>
llvm.func private @__cal_release_List(%ptr: !llvm.ptr) {
  // 1. Load tag to determine variant
  // 2. If Cons: recursively release the tail pointer
  // 3. Decrement refcount atomically
  // 4. If refcount reaches 0: call @free
}
```

These functions are generated on-demand when the pass encounters `cal.rc.release` operations on recursive types, identified by the `cal.recursive_type` attribute.

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

### Phase 4.2: Recursive Type Detection ✅

- [x] Implement `cal-detect-recursive-types` analysis pass (`CalPassesDetectRecursiveTypes.cpp`)
- [x] Add recursive field marking attributes (`cal.recursive_type`, `cal.recursive_fields`, `cal.recursive_token`)
- [x] Test with non-recursive types (`test/Dialect/Cal/detect-recursive-types.mlir`)
- [x] Pass registered in CalPasses.td and CalPasses.h

**Note on recursive type representation:**
MLIR types are structural, so truly self-referential types require either:
1. Type aliases (not currently supported)
2. Frontend-side unrolling to a fixed depth
3. Opaque pointer indirection at recursive fields

The pass detects recursion by analyzing same-named types appearing in field positions.
When the frontend generates code, recursive types will be represented with boxing
(e.g., `!llvm.ptr` for recursive fields), and the detection pass will identify
which operations need special memory management.

### Phase 4.3: Arena Insertion ✅

- [x] Implement `cal-insert-arenas` transformation pass (`CalPassesInsertArenas.cpp`)
- [x] Insert `cal.arena.create` at execution_body entry
- [x] Insert `cal.arena.destroy` before `cal.action_done` terminators
- [x] Mark recursive ops with `cal.arena_allocated` attribute
- [x] Mark FIFO ops with `cal.token_wrapped`/`cal.needs_token_unwrap` attributes
- [x] Test arena scoping correctness (`test/Dialect/Cal/insert-arenas.mlir`)
- [x] Pass registered in CalPasses.td and CalPasses.h

**Implementation notes:**
- The pass checks for `cal.recursive_type` or `cal.recursive_token` attributes set by the
  detection pass (Phase 4.2)
- Arena ops are only inserted when needed (execution bodies with recursive type operations)
- FIFO operations transferring recursive types are marked for later token transformation
- Actual token wrapping/unwrapping is deferred to LLVM lowering (Phase 4.5)

### Phase 4.4: State Variable RC ✅

- [x] Implement `cal-insert-rc-for-state` transformation pass (`CalPassesInsertRCForState.cpp`)
- [x] Mark state variables with `cal.rc_managed` attribute
- [x] Mark `cal.get` operations with `cal.rc_borrowed` attribute
- [x] Mark `cal.set` operations with `cal.rc_updated`, `cal.rc_release_old` attributes
- [x] Detect when `cal.set` needs `cal.rc_needs_alloc` (from arena) or `cal.rc_needs_retain` (from RC)
- [x] Test reference counting correctness (`test/Dialect/Cal/insert-rc-for-state.mlir`)
- [x] Pass registered in CalPasses.td and CalPasses.h

**Implementation notes:**
- The pass checks for `cal.recursive_type` attribute on `cal.create_state_var` ops
- State variable operations are annotated for later LLVM lowering:
  - `cal.get` values are borrows (no retain needed for read-only access)
  - `cal.set` must release old value and retain/alloc new value
  - Escape analysis determines if additional retains are needed
- Actual RC operations (rc.alloc, rc.retain, rc.release) are inserted during LLVM lowering

### Phase 4.5: LLVM Lowering (Inline Code Generation) ✅

The LLVM lowering generates all memory management code inline, without requiring
a separate C runtime library. This approach:
- Avoids external dependencies
- Enables better optimization (inlining, dead code elimination)
- Simplifies deployment (single binary output)

The `--convert-cal-memory-to-llvm` pass is implemented in
`lib/Conversion/CalMemoryToLLVM/CalMemoryToLLVM.cpp` and handles:

- [x] Arena implementation:
  - `!cal.arena` converts to `!llvm.ptr` (pointer to arena struct in memory)
  - Arena struct layout: `{ ptr base, i64 offset, i64 capacity }`
  - **Important:** Arena is pointer-to-struct (not struct by value) to enable in-place offset updates
  - `cal.arena.create`: malloc arena struct header (24 bytes) + malloc backing buffer (default 4KB)
  - `cal.arena.alloc`: aligned bump-pointer allocation with **in-place offset update**
  - `cal.arena.destroy`: free backing buffer + free arena struct
- [x] RC implementation:
  - `!cal.rc<T>` converts to `!llvm.ptr`
  - Memory layout: `[i32 refcount | payload]` (payload at offset 4)
  - `cal.rc.alloc`: malloc + init refcount to 1 + store payload
  - `cal.rc.retain`: `llvm.atomicrmw add` (thread-safe)
  - `cal.rc.release`: `llvm.atomicrmw sub` + conditional free when count reaches 0
  - `cal.rc.load`: load from payload offset (4 bytes after refcount)
  - `cal.rc.store`: store to payload offset
- [x] Token implementation:
  - `!cal.token<T>` converts to `!llvm.ptr`
  - `cal.token.wrap`: malloc + store (deep copy for FIFO transfer)
  - `cal.token.unwrap`: load + adopt ownership
  - `cal.token.consume`: free without unwrapping
- [x] Boxing operations:
  - `cal.box.in_arena`: arena allocation with **in-place offset update** + store value
  - `cal.unbox`: load from pointer
  - `cal.deep_copy`: pass-through for now (TODO: recursive copy for nested types)

**Usage:**
```bash
cal-opt --convert-cal-memory-to-llvm input.mlir
```

#### Type Conversions Summary

| CAL Type | LLVM Type | Notes |
|----------|-----------|-------|
| `!cal.arena` | `!llvm.ptr` | Pointer to `{ptr, i64, i64}` struct in memory |
| `!cal.rc<T>` | `!llvm.ptr` | Pointer to refcount+payload allocation |
| `!cal.token<T>` | `!llvm.ptr` | Pointer to token payload |

### Phase 5: Testing & Documentation

- [x] Add MLIR output tests for memory operations (`test/Conversion/CalMemoryToLLVM/cal-memory-to-llvm.mlir`)
- [ ] Add MLIR output tests for variant/product type lowering
- [ ] Add end-to-end execution tests for recursive types (List, Tree)
- [ ] Test with valgrind/asan for memory safety
- [ ] Document usage in CAL language guide

---

## 6. Remaining Work Summary

### Critical (Blocking End-to-End Use)

| Item | Status | Description |
|------|--------|-------------|
| **Variant/Product → LLVM** | ✅ Complete | Lower `!cal.variant` and `!cal.product` types to LLVM struct layout |
| **Type-aware Size Calculation** | ✅ Complete | Compute actual sizes in `rc.alloc`, `token.wrap`, `box.in_arena` based on payload types |
| **cal.deep_copy Arena Copy** | ✅ Complete | Generate copy code into target arena (shallow copy for now) |
| **cal.deep_copy Recursive** | ⚠️ Partial | Need recursive copy for deeply nested boxed fields in truly recursive types |

### Important (Correctness/Safety)

| Item | Status | Description |
|------|--------|-------------|
| **Arena Bounds Checking** | ✅ Complete | `arena.alloc`, `box.in_arena`, `deep_copy` now check capacity and call `abort()` on overflow |
| **RC for Nested Types** | ✅ Complete | Generates type-specific release functions for recursive variant types with pointer fields |
| **Pipeline Integration** | ✅ Complete | CalVariantToLLVM and CalMemoryToLLVM wired into `--lower-cal-to-llvm` pipeline |

### Nice-to-Have (Optimization)

| Item | Status | Description |
|------|--------|-------------|
| **Arena Growth** | ❌ Not Started | Automatically grow arena when capacity exceeded (instead of abort) |
| **Token Zero-Copy** | ❌ Not Started | Optimize token unwrap to adopt memory instead of copy |
| **Escape Analysis** | ❌ Not Started | Avoid RC retain when value doesn't escape action scope |

### Completed ✅

| Phase | Description |
|-------|-------------|
| 4.1 Types | `!cal.arena`, `!cal.rc<T>`, `!cal.token<T>`, `!cal.variant`, `!cal.product` in CalTypes.td |
| 4.2 Detection | `--cal-detect-recursive-types` pass marks recursive types |
| 4.3 Arena Insertion | `--cal-insert-arenas` pass adds arena create/destroy |
| 4.4 RC Annotation | `--cal-insert-rc-for-state` pass marks state variable RC needs |
| 4.5 Memory Lowering | `--convert-cal-memory-to-llvm` pass lowers arena/RC/token/boxing ops |
| 4.6 Variant Lowering | `--convert-cal-variant-to-llvm` pass lowers variant/product types and ops |
| 4.7 Integration Tests | End-to-end test in `test/Conversion/CalLoweringPipelines/algebraic-types-integration.mlir` |
| 4.8 Bounds Checking | Arena allocation ops now check capacity and abort on overflow |

---

## 6.1 Implementation Plan: Recursive RC Release

This section documents the implementation plan for full recursive reference counting
release of nested types (e.g., `List<T>`, `Tree<T>`). The current framework detects
nested types but does not recursively release RC fields within variants.

### Approach: Generate Per-Type Release Functions

The recommended approach generates a release function for each RC element type that
contains nested RC fields. These functions:

1. Atomically decrement the reference count
2. If count reaches zero:
   - Switch on variant tag (for variant types)
   - For each case, GEP to RC field(s) and recursively call release
   - Free the RC container memory

#### Example: Generated Release Function for `List<i32>`

```
// Type: !cal.variant<"List", [("Cons", [i32, !llvm.ptr]), ("Nil", [])]>
// The ptr in Cons is a boxed recursive reference to another List

llvm.func @__cal_release_List_i32(%rc_ptr: !llvm.ptr) {
  // 1. Atomic decrement refcount
  %refcount_ptr = llvm.getelementptr %rc_ptr[0, 0] : ...
  %old_count = llvm.atomicrmw sub %refcount_ptr, 1 : i32
  %c1 = llvm.mlir.constant(1 : i32) : i32
  %should_free = llvm.icmp "eq" %old_count, %c1 : i32
  llvm.cond_br %should_free, ^release, ^done

^release:
  // 2. Load payload (the variant value)
  %payload_ptr = llvm.getelementptr %rc_ptr[0, 1] : ...  // after refcount
  %tag_ptr = llvm.getelementptr %payload_ptr[0, 0] : ...
  %tag = llvm.load %tag_ptr : i32
  
  // 3. Switch on tag
  llvm.switch %tag : i32, ^done [
    0: ^cons,   // Cons case
    1: ^nil     // Nil case
  ]

^cons:
  // Cons has fields: [i32, !llvm.ptr (boxed tail)]
  // Field 0 (i32) - no release needed
  // Field 1 (ptr to tail) - recursive release
  %fields_ptr = llvm.getelementptr %payload_ptr[0, 1] : ...
  %tail_ptr_ptr = llvm.getelementptr %fields_ptr[1] : ...
  %tail_ptr = llvm.load %tail_ptr_ptr : !llvm.ptr
  
  // Check for null (Nil case or uninitialized)
  %null = llvm.mlir.zero : !llvm.ptr
  %is_null = llvm.icmp "eq" %tail_ptr, %null : !llvm.ptr
  llvm.cond_br %is_null, ^free, ^release_tail

^release_tail:
  // Recursive call to release the tail
  llvm.call @__cal_release_List_i32(%tail_ptr) : (!llvm.ptr) -> ()
  llvm.br ^free

^nil:
  // Nil has no fields - nothing to release
  llvm.br ^free

^free:
  // 4. Free the RC container
  llvm.call @free(%rc_ptr) : (!llvm.ptr) -> ()
  llvm.br ^done

^done:
  llvm.return
}
```

### Implementation Checklist

#### Phase 1: Helper Infrastructure ✅ Complete

- [x] **`needsCustomRelease(Type)`** — Check if a type requires a custom release function
  - Returns true if type is variant/product containing:
    - Boxed pointers (`!llvm.ptr`) to recursive types
  - Implemented as static function checking for pointer fields recursively

- [x] **`mangleReleaseFunctionName(Type)`** — Generate unique function names
  - Format: `@__cal_release_<TypeName>`
  - Examples: `!cal.variant<"List", ...>` → `@__cal_release_List`

- [x] **`getOrInsertFree()`** — Get or declare `@free(ptr)` function in module

#### Phase 2: Release Function Generation ✅ Complete

- [x] **`getOrGenerateReleaseFunction(ModuleOp, Type, ...)`** — Create the release function
  1. Check if function already exists (via symbol lookup)
  2. Create function with signature `(!llvm.ptr) -> ()`
  3. Generate atomic decrement and conditional branch
  4. For variant types: generate switch on tag
  5. For each variant case with pointer fields:
     - GEP to field, load pointer
     - Null check before recursive call
     - Recursively call `@__cal_release_<TypeName>`
  6. Generate final free and return

- [x] **Handle Recursion** — Self-referential types work via recursive function calls
  - The generated function calls itself for tail pointers

#### Phase 3: Integration with RCReleaseOpLowering ✅ Complete

- [x] **Modify `RCReleaseOpLowering::matchAndRewrite()`**
  1. Get element type from `!cal.rc<T>`
  2. Check `needsCustomRelease(T)` 
  3. If true: call `getOrGenerateReleaseFunction()` then emit `llvm.call @__cal_release_...(ptr)`
  4. If false: emit simple atomic decrement + conditional free (existing behavior)

- [x] **Cache Generated Functions** — Symbol table lookup prevents duplicates

#### Phase 4: Testing ✅ Complete

- [x] **Unit test: Recursive type** — `!cal.rc<!cal.variant<"List", [("Cons", [i32, !llvm.ptr]), ("Nil", [])]>>`
- [x] **Unit test: Simple variant** — `!cal.rc<!cal.variant<"Maybe", [("Some", [i32]), ("None", [])]>>` uses inline release
- [x] **Unit test: Multiple recursive types** — Different types (List, Tree) generate separate release functions
- [x] **Integration test** — Verified with existing `algebraic-types-integration.mlir`

#### Phase 5: Mutual Recursion Infrastructure ✅ Complete

- [x] **Pointee type lookup** — `getPointeeTypeForField()` function looks up `cal.pointer_field_types` module attribute
- [x] **Per-field release dispatch** — Each pointer field can call a different release function based on pointee type
- [x] **Self-recursion fallback** — When no annotation present, assumes pointer points to containing type
- [x] **Module attribute population** — `cal-detect-recursive-types` pass now populates `cal.pointer_field_types`
  - Detects recursive cycles via DFS on type dependency graph
  - For each pointer field in a recursive type, records the pointee type
  - Self-recursion: field points back to containing type
  - Mutual recursion: field points to different type in the cycle

**Note on mutual recursion detection:**
The detection pass analyzes embedded algebraic types. If a type field uses `!llvm.ptr` directly
(already boxed), the pass cannot infer what it points to. For full mutual recursion support:
1. The CAL frontend should emit unboxed recursive type references
2. A boxing transformation converts these to `!llvm.ptr` and records the mapping
3. Current implementation supports self-recursion fallback for pre-boxed IR

#### Phase 6: Runtime Verification ✅ Complete

All RC operations verified at runtime using `lli` (LLVM interpreter):

| Test | Exit Code | Description |
|------|-----------|-------------|
| Scalar RC | 42 | `cal.rc.alloc`/`load`/`release` with i32 |
| Variant RC | 100 | `cal.rc.*` with `!cal.variant<"Maybe">` |
| Nil release | 0 | Recursive release with Nil variant (no recursion) |
| Cons(null) release | 42 | Single Cons with null tail |
| Cons chain release | 100 | Two-element linked list with actual recursive release |

Test commands:
```bash
cd build
./bin/cal-opt --lower-cal-to-llvm test.mlir | ./bin/cal-translate --mlir-to-llvmir | lli
```

#### Future Enhancements (Not Yet Implemented)

- [ ] **Nested RC fields** — Direct `!cal.rc<U>` fields (not just `!llvm.ptr`)
- [ ] **Memory safety verification** — Valgrind/ASan testing
- [x] **Boxing transformation passes** — `cal-detect-recursive-types`, `cal-insert-arenas`, `cal-insert-rc-for-state`, `cal-materialize-rc-ops`

### Boxing Transformation Pass Pipeline

The boxing passes transform high-level CAL code with recursive algebraic types into explicit memory management:

```
1. cal-detect-recursive-types
   - Analyzes variant/product types for recursive fields
   - Marks operations with `cal.recursive_type` attribute
   - Identifies which variant fields need boxing

2. cal-insert-arenas  
   - Inserts cal.arena.create at start of cal.execution_body
   - Inserts cal.arena.destroy before cal.action_done
   - For execution bodies containing recursive type operations

3. cal-insert-rc-for-state
   - Marks state variables with `cal.rc_managed` attribute
   - Marks cal.get operations with `cal.rc_borrowed`
   - Marks cal.set operations with `cal.rc_release_old`, `cal.rc_needs_alloc`

4. cal-materialize-rc-ops
   - Transforms cal.create_state_var type from T to !cal.rc<T>
   - Inserts cal.rc.load after cal.get to extract the actual value
   - Inserts cal.rc.release (old) + cal.rc.alloc (new) around cal.set
```

**Example Pipeline:**
```bash
cal-opt input.mlir \
  --cal-detect-recursive-types \
  --cal-insert-arenas \
  --cal-insert-rc-for-state \
  --cal-materialize-rc-ops \
  --lower-cal-to-llvm
```

### Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Generation Location** | On-demand in `RCReleaseOpLowering` | Avoids separate pass, functions generated as needed |
| **Function Visibility** | `llvm.linkage<private>` | Internal implementation detail, enables inlining |
| **Null Pointer Handling** | Check before recursive call | Boxed fields may be null for base cases |
| **Atomic Operations** | `llvm.atomicrmw sub` | Thread-safe reference counting |
| **Mutual Recursion** | Module attribute + on-demand generation | `cal.pointer_field_types` maps fields to pointee types |

### Files Modified

| File | Changes |
|------|---------|
| `lib/Conversion/CalMemoryToLLVM/CalMemoryToLLVM.cpp` | Added helper functions `needsCustomRelease`, `mangleReleaseFunctionName`, `getPointeeTypeForField`, `getOrGenerateReleaseFunction`; modified `RCReleaseOpLowering` |
| `test/Conversion/CalMemoryToLLVM/cal-memory-to-llvm.mlir` | Added tests for recursive release (List, Tree types) and multiple recursive types |
| `test/Conversion/CalLoweringPipelines/algebraic-types-integration.mlir` | Integration tests for variant/product with RC |

---

## 7. Example: Full Pipeline

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

## 8. References

- [MLIR Dialect Definition](https://mlir.llvm.org/docs/DefiningDialects/)
- [MLIR Type System](https://mlir.llvm.org/docs/DefiningDialects/AttributesAndTypes/)
- [Rust Enum Layout](https://doc.rust-lang.org/reference/type-layout.html#reprc-enums-with-fields)
- [Swift Enum Implementation](https://github.com/apple/swift/blob/main/docs/ABI/TypeLayout.rst)
