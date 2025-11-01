# RFC: Structural elaboration with scf.if/scf.for and const-eval for CAL networks

This RFC defines a compile-time elaboration strategy for CAL networks that uses
MLIR's `scf.if` and `scf.for` to express structural conditionals and replication,
combined with a conservative constant-evaluation step so that conditions and loop
trip counts become constants. The end result is a fully elaborated `cal.network`
containing only instances, FIFOs, and connections—ready for existing lowering.

## Motivation

- Frontends can generate readable SSA-based structure using standard MLIR control
  ops (scf), while passing compile-time constants (e.g., NSTAGES) and pure helper
  functions (e.g., pow2) that must fold at compile time.
- We avoid inventing new structural-if/for ops when scf is sufficient and allows
  reuse of MLIR infrastructure (canonicalize, SCCP, loop unrolling).

## Source constraints (from frontend)

- All structure-driving values are constants by the time of elaboration:
  - if conditions (e.g., `NSTAGES > 1`)
  - loop bounds/steps (e.g., replication counts)
- Helper functions used in their computation are side-effect-free and receive
  constant arguments (eligible for const-eval).
- Type parameters are specialized to concrete MLIR types in the emitted IR.

## IR constraints and verifiers

- Structural CAL ops (instantiate/connect/fifo.create) are permitted inside
  nested regions (e.g., within `scf.if`/`scf.for`) provided there is an ancestor
  `cal.network`. Verifier rule: "must have ancestor cal.network".
- No value-level collections are required for structure (we can express all
  topology via scf + structural ops). Existing value-collection ops remain
  available and orthogonal.

## Pass pipeline

1) cal-const-eval (new)
   - Inline small, pure helper functions and run constant propagation so that
     structure-driving values become `arith.constant`.
   - Reject/diagnose if a structural decision remains dynamic where a compile-time
     constant is required by downstream passes.

2) elaborate-scf-structures (new)
   - If a branch condition is constant, inline the taken region and erase the
     `scf.if`.
   - If a loop trip count is constant, unroll the `scf.for` (cloning structural
     ops) and erase the loop.
   - Leave dynamic constructs intact (or diagnose when strict elaboration is
     requested by pipeline options).

3) Existing CAL transforms
   - Flatten hierarchical networks (inline network instances if/when supported).
   - Lower CAL to func/LLVM as already implemented.

## Hierarchy and recursion

- Short term: implement hierarchical flattening via network inlining (inline a
  child network body into the parent at the instance site, rewiring ports).
- Longer term: consider first-class network instance handles; not required for
  Butterfly when inlined.

## Function calls during elaboration

- Calls that feed structure must fold (const-eval). Other calls are allowed to
  remain as value producers; structural elaboration does not execute or reorder
  side-effecting calls.

## Example: Butterfly (outline)

- Compute: `N3 = pow2(NSTAGES-1)` and `nBF = (NSTAGES>1 ? 2 : 0)` via const-eval.
- Structure: shared edges (`In`→`Split.In`, `In`→`Twiddles.Trigger`, `Merge.Out`→`Out`).
- Conditional: `scf.if (NSTAGES>1)` then replicate `bf` with `scf.for i=0..nBF`.
- Elaboration removes `scf.*` and produces concrete instances and connects.

## Deliverables

- Verifier changes: ancestor `cal.network` check for structural ops.
- New passes (skeletons added):
  - `--cal-const-eval`
  - `--elaborate-scf-structures`
- Updated docs and tests demonstrating folding/unrolling and the elaborated net.

## Open items

- Exact const-eval policy and allowed dialects (start with arith + small func subset).
- Optional: zero-length arrays or structural-if to handle shape divergence in value paths.
- Network instantiation vs inlining timeline.
