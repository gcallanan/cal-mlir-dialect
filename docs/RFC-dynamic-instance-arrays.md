# RFC: Dynamic Instance Arrays for CAL Dialect

## Summary

Introduce first-class support for dynamic-sized instance arrays in the CAL dialect. Arrays may have one or more dynamic dimensions (?, mixed ND like [?,6], or fully dynamic per-dimension), be initialized with unknown extents, and obtain concrete (or partially concrete) shapes via operands, loop-bound analysis, or remain dynamic until elaboration. The design provides:

- Extensible types for dynamic array shapes (1D and ND) for both concrete-entity and interface-typed handles
- SCF-friendly construction with `cal.instance.array.init` and `cal.instance.array.set`
- ND indexing via `cal.instance_at` and array-based structural wiring via `cal.connect`
- Phased verification (early best-effort, late definitive)
- Shape inference pass recognizing common SCF patterns
- Elaboration strategy for static or dynamic shapes

This RFC preserves backward compatibility with existing static-extent instance arrays.

## Motivation

Structural CAL IR needs to:

- Represent large replicated actor grids whose extents are not compile-time constants
- Drive construction and wiring from parameters (e.g., w,h) and data-dependent predicates (via scf.if)
- Keep the IR high-level and legible until elaboration while allowing downstream shape inference and late verification

Examples: parametric Game of Life grids, stencil networks, tiled pipelines with runtime sizes.

## Types

Add dynamic extent forms to instance array types.

- Concrete-entity instance arrays:
  - 1D static: `!cal.instance.array<@Actor, 16>` (existing)
  - 1D dynamic: `!cal.instance.array<@Actor, ?>`
  - ND static: `!cal.instance.array<@Actor, [4,4]>`
  - ND mixed: `!cal.instance.array<@Actor, [?, 6]>`
- Interface-typed instance arrays:
  - 1D dynamic: `!cal.instance.array.iface<@Iface, ?>`
  - ND mixed: `!cal.instance.array.iface<@Iface, [?,?]>`

Notes:

- Rank must be known; each dimension can be static (i64) or dynamic (?)
- Printing uses `?` consistent with tensor/memref

### TableGen sketch (CalTypes.td)

```tablegen
// Pseudocode sketch – actual integration will reuse existing Cal_Instance/Cal_InterfaceInstance array types
// and extend them with a DimList that can hold either i64 or dynamic markers.

class Cal_ArrayDim;
class Cal_StaticDim<I64Attr dim> : Cal_ArrayDim;
class Cal_DynamicDim : Cal_ArrayDim; // printed as '?'

def Cal_InstanceArray : Type<CPred<"isCalInstanceArrayType($_self)">, "CAL instance array"> {
  // payload: entity symbol ref + list<Cal_ArrayDim>
}

def Cal_InterfaceInstanceArray : Type<CPred<"isCalInterfaceInstanceArrayType($_self)">, "CAL interface instance array"> {
  // payload: interface symbol ref + list<Cal_ArrayDim>
}
```

## Ops

### `cal.instantiate_array` – dynamic shape

- Current: `cal.instantiate_array @A count(N) : !cal.instance.array<@A, N>`
- New: support dynamic extents via dims operands:
  - `cal.instantiate_array @A dims(%h) : !cal.instance.array<@A, ?>`
  - `cal.instantiate_array @A dims(%h,%w) : !cal.instance.array<@A, [?,?]>`
  - Mixed: static+dynamic within the same type
- Verifier:
  - Number of dims operands equals number of `?` in the result type
  - If `count(N)` provided for a `?` dim, treat as static dim
  - If some `?` have neither `count` nor `dims`, leave dynamic; emit remark (not error)

Assembly sketch:

```mlir
$actorRef (`count` `(` $count `)`) ? (`dims` `(` $dims `)`)? (`basename` `(` $baseName^ `)`)? (`(` $params `:` type($params)^ `)`) ? attr-dict `:` type($handlesArray)
```

### `cal.instance.array.init` – dynamic shape init

- New operands: pass index values for each `?` dim
- Examples:
  - `%arr = cal.instance.array.init %n : !cal.instance.array<@A, ?>`
  - `%mat = cal.instance.array.init %h, %w : !cal.instance.array<@A, [?,?]>`
- Static arrays keep the old zero-operand form

### `cal.instance_at` – ND indexing

- Extend to accept variadic index operands for ND
- Verify index count == rank; check constant bounds when dim is static

Assembly:

```mlir
$array `[` $indices `]` attr-dict `:` type($array) `,` type($indices) `->` type($handle)
```

### `cal.instance.array.set` – ND indices

- Already drafted in stubs; enforce index count == rank; bounds when static

Assembly:

```mlir
$array `[` $indices `]` `,` $value attr-dict `:` type($array) `,` type($value) `->` type($result)
```

### `cal.connect` – array endpoints with dynamic indices

Evolve the op to carry variadic index lists explicitly (no hard dependency on sugar):

- Arguments:
  - src: instance handle OR instance array
  - srcIndices: `Variadic<Index>` (optional)
  - srcPort: StrAttr (ignored for network FIFO SSA)
  - dst: instance handle OR instance array OR network FIFO SSA
  - dstIndices: `Variadic<Index>` (optional)
  - dstPort: StrAttr (ignored for network FIFO SSA)
  - capacity: Optional I64Attr
- Verifier:
  - Do not require constant indices; accept SSA
  - Port-name validation for concrete entities only; interface-typed handles are checked late

Assembly examples:

```mlir
cal.connect %src[%i,%j] : !cal.instance.array.iface<@OutOnly, [?,?]> "out" -> %dst[%p,%q] : !cal.instance.array<@Cell, [?,?]> "SE" capacity(8)
cal.connect %src : !cal.instance<@Edge> "out" -> %dst[%k] : !cal.instance.array<@Cell, ?> "N"
cal.connect %netIn : !fifo.output_port<i32> -> %dst[%k] : !cal.instance.array<@Cell, ?> "in0"
```

## Verification (phased)

- Early (best effort):
  - If all dims static: enforce completeness and OOB checks
  - If dynamic dims: detect obvious duplicates, recognize canonical SCF nests mapping to array dims; otherwise emit remark “completeness unknown”
- Late (after structural elaboration):
  - Verify port names against concrete entity symbols; tolerate interface-typed handles until resolution

Add pass options:

- `--allow-dynamic-indices` (default: on) — relaxes early errors on dynamic indices in connects
- `--array-fills-warn-dynamic` (default: off) — warns when completeness is not provable

## Shape inference

New pass: `cal-infer-instance-array-shapes`

- Recognizes patterns like:
  - `scf.for %i = 0..%H` and `scf.for %j = 0..%W` with `array.set %arr[%i,%j]`
  - Infers dims = (%H, %W) for `?` dims
- Partial inference supported (fill some `?`), leave the rest dynamic with remark

## Structural elaboration

- If dims concretize (const-eval): expand to explicit instances/FIFOs as today
- If dims remain dynamic: preserve array values and array-indexed connects; optional fallback: lower to scf loops that extract handles (`instance_at`) and emit scalar connects

## Backward compatibility

- Existing static forms unaffected
- Parsers remain backward compatible; new operands are optional

## Examples

Dynamic 1D construction and wiring:

```mlir
%c0 = arith.constant 0 : index
%c1 = arith.constant 1 : index

%arr = cal.instance.array.init %n : !cal.instance.array<@Edge, ?>
scf.for %i = %c0 to %n step %c1 {
  %h = cal.instantiate @Edge : !cal.instance<@Edge>
  %arr = cal.instance.array.set %arr[%i], %h : !cal.instance.array<@Edge, ?>, !cal.instance<@Edge> -> !cal.instance.array<@Edge, ?>
}

cal.connect %arr[%k] : !cal.instance.array<@Edge, ?> "out" -> %sink : !cal.instance<@Sink> "in"
```

Dynamic 2D with interface-typed sources and concrete cell array:

```mlir
%src = cal.instance.array.init %H, %W : !cal.instance.array.iface<@OutOnly, [?,?]>
%cells = cal.instance.array.init %H, %W : !cal.instance.array<@Cell, [?,?]>

// fill src with Edge or Cell-as-source under scf.if
// ...

cal.connect %src[%i+1,%j+1] : !cal.instance.array.iface<@OutOnly, [?,?]> "out"
         -> %cells[%i,%j] : !cal.instance.array<@Cell, [?,?]> "SE" capacity(3)
```

## Implementation plan

Milestones:

1) Types + parser/printer for dynamic dims (1D/ND) for both array kinds
2) Extend array.init to accept dims operands; tests
3) ND indices for instance_at + verify; tests
4) Connect op operand structure to carry variadic indices and tolerate dynamic indices; parser/printer; tests
5) Shape inference pass; docs
6) Structural elaboration tolerance for dynamic arrays; pass option; tests
7) Late port verification tolerance + post-elaboration checks; tests
8) Examples and migration notes; docs updates

## Migration and docs

- Update `docs/InstanceArrays-ND-and-SCF.md` with dynamic forms and guidance
- Update `docs/VerifyConnectPorts.md` to describe late checks for interface-typed handles
- Provide a parametric GoL example leveraging dynamic arrays and nested scf.for connects

## Open questions

- Should completely rank-dynamic arrays be permitted (omit rank)? Proposed: no — keep rank fixed for verifiers and printers.
- Should we allow dynamic reshaping of arrays? Proposed: out-of-scope for this RFC; construct a new array value instead.
- Should connect capacity accept SSA values? Proposed: keep I64Attr for now; consider SSA in a future RFC.

## Appendix: TableGen deltas (indicative)

### CalOps.td — cal.instantiate_array (dynamic dims)

```tablegen
def Cal_InstantiateArrayOp : Cal_Op<"instantiate_array", []> {
  let arguments = (ins
    FlatSymbolRefAttr:$actorRef,
    OptionalAttr<I64Attr>:$count,                // legacy 1D static
    Variadic<Index>:$dims,                       // new: per-? dims
    OptionalAttr<StrAttr>:$baseName,
    Variadic<AnyType>:$params
  );
  let results = (outs Cal_InstanceArray:$handlesArray);
  let hasVerifier = 1;
  let hasCustomAssemblyFormat = 1;
}
```

### CalOps.td — cal.instance_at (ND indices)

```tablegen
def Cal_InstanceAtOp : Cal_Op<"instance_at", []> {
  let arguments = (ins AnyType:$array, Variadic<Index>:$indices);
  let results = (outs AnyType:$handle);
  let assemblyFormat = "$array `[` $indices `]` attr-dict `:` type($array) `,` type($indices) `->` type($handle)";
  let hasVerifier = 1;
}
```

### CalOps.td — cal.connect (array indices)

```tablegen
def Cal_ConnectOp : Cal_Op<"connect", [AttrSizedOperandSegments]> {
  let arguments = (ins
    AnyType:$src,
    Variadic<Index>:$srcIndices,     // optional
    StrAttr:$srcPort,
    AnyType:$dst,
    Variadic<Index>:$dstIndices,     // optional
    StrAttr:$dstPort,
    OptionalAttr<I64Attr>:$capacity
  );
  let hasCustomAssemblyFormat = 1;
  let hasVerifier = 1;
}
```

This RFC is implementation-ready and backwards compatible. Once approved, we can stage changes per milestone with tests and docs.
