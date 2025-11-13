# CAL Network Elaboration Pipeline (Experimental `cal-network-elab`)

This document describes the staging and invariants of the unified CAL network elaboration pipeline.

## Stages Overview

| Stage | Pass | Purpose | Guarantees After Stage |
|-------|------|---------|------------------------|
| A | `ConstJITResolve` | Always-JIT replacement for legacy constant evaluation (no static pow2 folding) | All eligible numeric const ops JIT-marked; no premature folding of semantic intrinsics |
| B | `ParamSpecialize` | Clone actors/networks on constant parameter tuples | Symbol bodies specialized; original preserved; no duplicate specialization |
| C0 | `InferCalInstanceArrayShape` | Static extent upgrade for dynamic instance arrays (loops, init, literal, concat) | All trivially constant shapes made static; dynamic forms retained when any dimension unresolved |
| C1 | `ElaborateScfStructures` | Structural normalization (legacy placeholder) | Simplifies SCF for downstream array extraction; does not mutate array element types |
| C2 | `NetworkElementsElab` | Array-builder loop unrolling & trivial const `scf.if` folding | Removes array-construction loops; preserves `cal.instance.array.set`, heterogeneity, predicates; no shape changes |
| E | `FlattenCalNetworks` | Symbolic network flattening (hierarchy removal) | Single-level network; ordering constraints maintained |
| Fanout | `InsertFanoutOnMultiSink` | Mandatory fanout synthesis / multi-sink normalization | Each multi-sink connection explicit fanout representation |
| D | `ElaborateCalEntities` | Materialize concrete `fifo.create` + `cal.create_instance` | Symbolic handles lowered to executable entities |
| F1 | `VerifyInstanceArrayFills` | Ensure arrays fully populated or explicitly marked | Array completeness & bounds basic checks |
| F2 | `VerifyConnectPorts` | Port name/type consistency | Connect ops reference valid ports |
| F3 | `VerifyInstanceArrayStaticUsage` | Static index bounds verification | All constant indices in static arrays are in-range |

## Key Invariants

1. Shape freezing occurs only in C0; later passes must treat element types and extents as immutable.
2. NetworkElementsElab (C2) never introduces or removes ports, only rewrites loop shells.
3. Fanout synthesis must occur after flattening (E) but before concrete entity elaboration (D) to avoid duplicating concrete channels.
4. Verification passes (F*) are side-effect free; they may fail the pass manager but never mutate IR.
5. Dynamic arrays with runtime extents are preserved until a later lowering stage (outside this pipeline).

## Debug Attributes

- `cal.shape_inferred`: Added by C0 when a dynamic array becomes static.
- `from_create_instance`: Marks calls originating from symbolic instantiation when lowered.
- `cal.non_preemptive`: Propagated scheduling hint onto calls.

## Failure Modes

| Pass | Typical Error Condition |
|------|-------------------------|
| C0 | Non-positive trip count; mismatched loop rank; malformed concat inputs |
| C2 | Unsupported loop pattern (multiple unrelated sets per iteration) |
| F3 | Out-of-bounds constant index on static array |

## Extensibility

Future work will factor `FlattenCalNetworks` into pure symbolic flatten + separate concrete elaboration, and introduce reachability pruning + interface satisfaction verification as an additional F-stage (`ReachabilityPruneAndVerify`).

## Recommended Invocation

```
cal-opt input.mlir -cal-network-elab | ... (conversion pipeline)
```

For targeted shape inference only:
```
cal-opt input.mlir -infer-cal-instance-array-shape
```

## Test Coverage Map

| Feature | Test File |
|---------|-----------|
| 1-D loop shape inference | `infer-shape-simple-init-loop.mlir` |
| 2-D nested loop shape inference | `infer-shape-loop-nest.mlir` |
| Literal staticization | `infer-shape-literal.mlir` |
| Concat staticization | `infer-shape-concat.mlir` |
| Unrolling & heterogeneity | `network-elements-elab-hetero.mlir` |
| n-D unrolling | `network-elements-elab-nd-loop.mlir` |
| Static usage verification | `verify-static-usage.mlir` |

## Notes

- Multi-dimensional literal and concat support remains 1-D; extend IR semantics before adding inference logic.
- Shape inference intentionally avoids speculative dimension arithmetic beyond simple constant evaluation.
- Additional canonicalizations should run after C0 to exploit static shapes (e.g., removal of redundant bounds checks).
