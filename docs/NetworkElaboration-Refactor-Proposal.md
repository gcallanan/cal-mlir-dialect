# Network Elaboration & Const Evaluation Audit and Refactor Proposal

## 1. Executive Summary
The current CAL network elaboration pipeline relies on a combination of symbolic construction passes (instance arrays, connects), constant evaluation (CalConstEval), structural loop/predicate elaboration (ElaborateScfStructures / ElaborateCalEntities / InferCalInstanceArrayShape), and hierarchical flattening (FlattenCalNetworks) before lowering to `func`/LLVM. While each pass individually solves a focused problem, their responsibilities overlap (specialization vs inlining vs pruning vs constant folding) and ordering constraints are implicit.

This proposal audits the existing behavior (with focus on `cal-const-eval` and `flatten-cal-networks`) and recommends a staged, contract-driven architecture that:
- Separates pure constant/value propagation from structural specialization.
- Makes network flattening incremental and idempotent.
- Establishes explicit IR invariants after each stage.
- Introduces capability flags and pass pipelines that are composable ("structural only", "full elaboration", "fast-path compile", etc.).
- Reduces duplication of pow2 / recursion pattern folding logic.
- Simplifies debugging by surfacing progress metrics uniformly.

## 2. Current Pipeline Audit
### 2.1 Symbolic IR Starting Point
Key symbolic ops: `cal.instantiate`, `cal.instantiate_array(.iface)`, `cal.instance_at`, `cal.connect` (with optional array index sugar), instance array construction helpers (`cal.instance.array.{init,set,literal,concat}`), interface conformance ops (`cal.interface`, `cal.implements`, `cal.instance.cast`), and SCF control flow shaping the construction (loop nests creating arrays).

### 2.2 Principal Passes & Roles
| Pass | Current Responsibilities | Overlaps / Issues |
|------|--------------------------|-------------------|
| CalConstEval (`cal-const-eval`) | Inline small helper `func.func`, multi-phase pow2 folding (3 passes), multi-stage specialization cloning (`$spec`, `$specLate`), optional network inlining, pruning unreachable symbols, JIT proto, late DCE of helpers | Combines const-prop, specialization, pruning, network inlining → hard to reason about ordering; duplicates pow2 fold logic; mixes symbol graph pruning with evaluation.
| FlattenCalNetworks (`flatten-cal-networks`) | Elaborates symbolic constructs → concrete `fifo.create` + `cal.create_instance`; resolves array sugar; handles dynamic index allowances; validates ports; capacity conflict detection; flattens hierarchical networks; deterministic naming; optional pruning; collects stats | Performs both *elaboration* and *flattening*; partial connectivity logic entwined with materialization rules; capacity + interface conformity checks partly duplicated with later verifiers.
| ElaborateScfStructures | Unrolls static `scf.for`, selects branches of `scf.if` with constant predicates, cloning structural ops into parent network | Depends on reliable constant evaluation; interacts with specialization done earlier.
| InferCalInstanceArrayShape | Rewrites dynamic array types to static when loop bounds known | Needs constants early; ordering relative to CalConstEval/pow2 folding crucial.
| ElaborateCalEntities | Unrolls static loops building arrays into straight-line sets without destroying array SSA | Overlaps with `ElaborateScfStructures` for loop handling if ordering unclear.
| VerifyConnectPorts | Late verification of port names after elaboration/specialization | Some port name validation already inside FlattenCalNetworks.
| InsertFanoutOnMultiSink | Synthesizes fanout actors pre-elaboration | Requires stable symbolic connect semantics.
| ConvertCalToFunc | Assumes fully elaborated network, no symbolic ops; expects actors with `cal.execution_body` only | Requires earlier passes to remove `cal.action` and finalize ports.

### 2.3 Observed Pain Points
1. **Pass Scope Creep**: CalConstEval does specialization, folding, pruning, JIT, and optional inlining — difficult to test incrementally.
2. **Redundant Pow2 Folding Logic**: Implemented in 3 sub-phases plus a late phase; each replicates pattern matching.
3. **Implicit Ordering**: Users must guess ordering of CalConstEval vs InferCalInstanceArrayShape vs FlattenCalNetworks for reliable constant propagation.
4. **Mixed Error vs Skip Semantics**: `allow-partial-connectivity` and `allow-dynamic-indices` switch from hard error to silent skipping; later passes may never revisit skipped symbolic fragments (risk of latent dead code). 
5. **Specialization Explosion**: `$spec` and `$specLate` cloning may generate many symbols; pruning only runs after full evaluation; missed dedup opportunities.
6. **Interface Cast Conformance**: Conformance validation partly integrated inside FlattenCalNetworks. Centralizing would simplify maintenance.
7. **Pruning Responsibility**: Both CalConstEval and FlattenCalNetworks can prune networks/actors; separation of concerns is blurred.
8. **Diagnostic Fragmentation**: Stats emitted only from flatten pass; specialization, const-eval, pruning have no unified progress metrics.
9. **Symbol Identity Stability**: Multiple pass clones risk unstable debug references (important for caching and incremental builds).
10. **JIT Const Eval Prototype**: Bundled inside CalConstEval; hard to gate independently or fallback gracefully.

### 2.4 Current (Typical) Ordering Guess
```
cal-const-eval → infer-cal-instance-array-shape → elaborate-cal-entities → elaborate-scf-structures → flatten-cal-networks → verify-connect-ports → convert-cal-to-func → lower-cal-to-llvm
```
This sequence is not formally enforced; deviations lead to partial elaboration or missing constants.

### 2.5 IR Invariants (Implicit)
Stage | Assumed Invariant (Current) | Reality
------|-----------------------------|---------
After CalConstEval | Many helper calls folded; some networks specialized; symbolic constructs remain | Mixed specialized & original; pow2 folding maybe partial; dynamic arrays possibly unresolved.
After FlattenCalNetworks | No nested networks; all connects materialized (unless skipped) | Skipped dynamic indices remain; partial connectivity leaves symbolic ops.
Before ConvertCalToFunc | No symbolic network ops; actors have execution bodies | Might still have symbolic arrays if earlier passes skipped.

## 3. Goals for Refactor
1. **Single Responsibility Passes**: Isolate const folding, specialization, pruning, flattening.
2. **Deterministic Multi-Stage Pipeline** with explicit stage outputs:
   - Stage A: Const & Shape Resolution
   - Stage B: Structural Specialization (parameter cloning)
   - Stage C: Array / Loop Elaboration (without flattening networks)
   - Stage D: Network Elaboration (connect materialization) & Validation
   - Stage E: Hierarchical Flattening (pure inlining of networks)
   - Stage F: Pruning & Final Verification
3. **Unified Metrics**: Each stage emits a `cal.stats` structured attribute / remark (JSON-like) to facilitate tooling.
4. **Always-JIT Const Evaluation**: Stage A must JIT-evaluate pure helper functions (including pow2-like recurrences); no separate static pow2 folding utility.
5. **Explicit Attributes / Tags**: Use namespaced attrs: `cal.stage`, `cal.specialized`, `cal.elab.skipped.reason`, `cal.const.folded`, `cal.flatten.origin`.
6. **Config Profiles**: Preset pipelines (`--cal-elab=fast`, `--cal-elab=debug`, `--cal-elab=full`) controlling optionality (JIT, aggressive specialization, partial connectivity).
7. **Deterministic Symbol Naming**: Provide stable hashing scheme across stages: `<orig>$spec$H<short-hash>`; avoid multiple `$specLate` variants.
8. **Incremental Re-run Safety**: Re-executing Stage D/E should be idempotent (detect already elaborated constructs via attributes, skip with metrics).
9. **Centralized Pruning**: Only Stage F performs reachability pruning; earlier stages never erase symbols.
10. **Clear Failure Modes**: Distinguish unresolved dynamic semantics vs unsupported feature with structured diagnostics.

## 4. Proposed Future Pass Graph
```
[A] ConstJITResolvePass
    - Always JIT-evaluate pure helper calls with constant operands (incl. pow2-like)
    - Optional small inliner or use global inliner flag for trivial pure helpers
    - Array shape inference when derivable from constants

[B] ParamSpecializePass
    - Clone actors/networks when leading params constant (single pass, no late sweep)
    - Maintain spec cache; dedupe identical attr sets

[C] NetworkElementsElabPass
    - Elaborate network elements (entities and structural instance arrays) without flattening networks
    - Extract/normalize array construction from static scf.for (init/set → instantiate_array or literal/concat)
    - Fold scf.if constant branches when they guard element/array construction

[E] NetworkFlattenPass
    - Pure hierarchical inline of network instances
    - Deterministic naming, no pruning

[Fanout] InsertFanoutAfterFlattenPass (symbolic)
    - Insert symbolic fanout instances on multi-sink connects in the flattened (still symbolic) network
    - Deterministic naming; provenance tagging for generated symbols/instances

[D] NetworkElaboratePass (concrete, runs after Fanout)
    - Replace symbolic instantiate/array/connect ops with concrete fifo + create_instance
    - Enforce port arity and interface conformance
    - Tag skipped items (`cal.elab.skipped.reason`) instead of silent omission

[F] ReachabilityPruneAndVerifyPass
    - Compute top; prune unreachable networks/actors
    - Verify port names (absorbs VerifyConnectPorts)
    - Remove dead helper functions

[G] FinalActorLowering / ConvertCalToFunc (existing)
```
Pipeline name (only advertised pipeline): `cal-network-elab`

Execution order: A → B → C → E (symbolic flatten) → Fanout (symbolic) → D (concrete elaboration) → F → G

## 5. Detailed Contracts & Invariants
### Stage A (ConstJITResolve)
Inputs: arbitrary symbolic CAL + helper funcs.  
Outputs:
- All simple arithmetic reduced.
- Pure helper calls with constant operands are JIT-evaluated (including pow2-like) and folded.
- Helper functions may be inlined only if pure & single block (optional).
- Array types upgraded to static extents when derivable from constants.  
Invariants:
- No symbol cloning yet.
- Attribute `cal.const.jit` marks JIT-folded sites.

### Stage B (ParamSpecialize)
Inputs: IR with constants resolved.  
Outputs:
- Each specialized clone has identical port signature to original.
- Original symbol retained; clones referenced by instantiate ops.
- Attribute `cal.specialized.params` lists indices specialized.  
Invariants:
- No network inlining.
- No recursive specialization (one pass – rely on Stage A for constant propagation first).

### Stage C (NetworkElementsElab)
Outputs:
- Static loop nests constructing instance arrays replaced by canonical array constructions.
- Prefer `cal.instantiate_array` with static count; otherwise use `cal.instance_array.literal/concat` or normalized `init/set`.
- `scf.for` used purely for array construction erased if fully static; conditions in `scf.if` folded when guarding element/array construction.
Invariants:
- No connect materialization yet.

### Stage D (NetworkElaborate)
Outputs:
- No remaining `cal.instantiate`, `cal.instantiate_array`, `cal.instance_at`, or symbolic `cal.connect` except those tagged with `cal.elab.skipped.reason` (dynamic index, partial connectivity, interface unresolved).
- Each materialized FIFO has `cal.name` and `cal.channel.src/dst` attrs with instance + port ordinal.
Invariants:
- All concrete instance creation uses `cal.create_instance` only.

### Stage E (NetworkFlatten)
Outputs:
- No nested `cal.create_instance` of networks (only actors).
- `cal.network` bodies contain only fifo ops, constants, actor instances, prints.
- Attribute `cal.flatten.origin` on cloned ops referencing source symbol.

### Stage F (Prune & Verify)
Outputs:
- Exactly one top network retained (explicit or auto-detected) plus reachable actors.
- All ports referenced in connects valid; if invalid, error (no silent skip).
- Stats attribute: `cal.stats = {"flattened":N, "specialized":M, "pruned":K, ...}` aggregated from prior passes.

## 6. Refactor Steps (Incremental Plan)
1. Introduce ConstJITResolvePass (replace CalConstEval): always JIT pure helper calls; remove static pow2 folding; keep strict timeouts and purity checks.
2. Split specialization into new ParamSpecializePass (move spec cache, remove late sweep, unify naming scheme).
3. Implement StructuralLoopElabPass (unroll static array-construction loops; fold constant scf.if) without flattening.
4. Split FlattenNetworks into NetworkFlattenPass (symbolic-only) and NetworkElaboratePass (concrete-only). Ensure order E → Fanout → D in the pipeline.
5. Add InsertFanoutAfterFlattenPass (symbolic) to run after flatten and before elaboration; remove earlier fanout insertion from other pipelines.
6. Move pruning/port verification into ReachabilityPruneAndVerifyPass (merge VerifyConnectPorts).
7. Introduce structured status attributes and a unified metrics emitter `CalStatsCollector`.
8. Register the single pipeline `cal-network-elab` with order: A → B → C → E → Fanout → D → F.
9. Deprecate old pipelines/options with compatibility shims (emit warnings) and update README/docs (FlattenCalNetworks.md → NetworkFlatten.md; this proposal updated accordingly).

## 7. Testing Strategy
### 7.1 Lit Test Matrix
Dimension | Cases
----------|------
Const Folding | pow2 recursive, iterative, mixed arithmetic
Specialization | Multiple constant params, mixed dynamic/constant, signature mismatch
Loop Elab | 1D array construction, nested perfect loops, dynamic bound skip
Network Elab | Array indices (static/dynamic), partial connectivity, interface casts
Flatten | Hierarchical depth 2–3, cycle detection
Prune & Verify | Multiple network symbols, ambiguous top, invalid port names
JIT (optional) | Simple pure helper returning int/float, timeout budget test

### 7.2 Invariant Tests
- After each stage pipeline, FileCheck patterns assert removal/presence of expected ops.
- Stats attribute presence and JSON contents validated.
- Deterministic naming by hashing: golden test comparing stable names across runs.

### 7.3 Performance & Regression
- Micro-bench: record pass run times before/after split; ensure no ballooning.
- Symbol count: assert reduced clone explosion vs earlier `$specLate` strategy.

### 7.4 Fallback & Flags
- Tests with `--cal-elab=fast` ensure pipeline completes without specialization stages.
- Negative tests enforce errors for dynamic indices when not allowed.

## 8. Risk & Mitigations
Risk | Mitigation
-----|-----------
Increased pass count overhead | Combine trivial passes when profiling shows negligible cost; enable grouping pipeline registration.
User confusion over new names | Provide alias options and transitional warnings.
Hidden dependencies on old attributes | Introduce adapter pass translating legacy attrs to new scheme until migration complete.
JIT instability / environment-specific failures | Gate behind env var + option; fallback silently to interpreter constant folding.

## 9. Migration Guidelines
Phase | Action | User Impact
------|--------|------------
Phase 1 | Introduce pow2 utility + shrink CalConstEval | None (behavior same)
Phase 2 | Add ParamSpecializePass; disable specialization in CalConstEval | Slight pipeline change (update docs) 
Phase 3 | Extract NetworkElaboratePass; keep FlattenCalNetworks functioning (internally calls new pass first) | Transparent, emit deprecation remark
Phase 4 | Introduce ReachabilityPruneAndVerifyPass; remove pruning from others | Users may need to add pass in custom pipelines
Phase 5 | Final removal of old options; rename passes | Update build scripts

## 10. Open Questions
1. Should specialization be iterative or single-pass? (Proposal: single-pass + rely on Stage A for constants.)
2. Retain partial connectivity skipping or force explicit repair passes? (Proposal: keep skip with tagged reason; add later "ConnectivityRepairPass".)
3. JIT evaluation caching lifetime: per-pass or module attribute persisted? (Proposal: per-pass ephemeral; attribute optional for debugging.)
4. Interface array elaboration for ND dynamic shapes — handle earlier or postpone? (Postpone to future extension of Stage D.)

## 11. Implementation Checklist
- [ ] ConstJITResolvePass (replace CalConstEval, always JIT; remove pow2 utility and late pow2 phases)
- [ ] ParamSpecializePass
- [ ] StructuralLoopElabPass
- [ ] NetworkFlattenPass (symbolic)
- [ ] NetworkElaboratePass (concrete)
- [ ] ReachabilityPruneAndVerifyPass (merge VerifyConnectPorts)
- [ ] Stats collector util + attributes
- [ ] Register `cal-network-elab` pipeline & update README
- [ ] Compatibility adapter for deprecated options
- [ ] Test suite expansion

## 12. Appendix: Attribute Schema (Draft)
Attribute | Kind | Example | Meaning
----------|------|---------|--------
`cal.const.folded` | unit | on `func.call` replaced | Const evaluation happened.
`cal.specialized.params` | array<i32> | `[0,2]` | Indices of params folded into clone.
`cal.specialized.origin` | string | `MyActor` | Source symbol for clone.
`cal.elab.skipped.reason` | string | `dynamic-index` | Why symbolic op left intact.
`cal.channel.src` / `cal.channel.dst` | dict | `{inst: "N.A.1", port: 0}` | Endpoints for fifo.
`cal.flatten.origin` | string | `ChildNet` | Source network symbol inlining provenance.
`cal.stats` | dict | `{"stage":"E","flattened":12}` | Stage metrics.

## 13. Conclusion
Splitting concerns and formalizing stage invariants will make the network elaboration pipeline more maintainable, testable, and performant. This proposal provides a roadmap for incremental adoption while preserving backward compatibility and enabling richer diagnostics and tooling.

---
*Prepared: 2025-11-12*
