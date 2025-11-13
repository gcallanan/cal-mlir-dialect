# ConstJITResolve ExecutionEngine Design

## 1. Goals
- Evaluate and fold calls to pure helper functions (incl. self-recursive) with constant operands using the MLIRExecutionEngine (LLJIT backend).
- Support integer and floating point scalars initially (i1, i32, f32, f64).
- Preserve determinism and safety; never execute side-effecting operations during folding.
- Reuse a single ExecutionEngine instance per pass invocation for performance.
- Provide graceful fallback (existing interpreter) when JIT compilation fails or function deemed unsafe.

## 2. High-Level Flow
1. Scan module for candidate `func.func` operations.
2. Run enhanced purity & side-effect analysis (transitive): build call graph; mark pure roots.
3. For each pure call site with constant operands:
   - Isolate callee + required pure transitive callees into a temporary `ModuleOp`.
   - Lower isolation module to LLVM dialect (arith/scf/func/complex/memref bufferization).
   - Materialize a trampoline wrapper with C ABI signature: `extern "C" <ret_ty> @_jit_trampoline(<arg types>);` forwarding to original function.
   - Invoke ExecutionEngine to compile on-demand (cache compiled pointer by signature & symbol name).
   - Execute trampoline with marshalled constant operands.
   - Replace original call op with `arith.constant` (or sequence for multi-result in future) + attach metadata attribute `jit.folded_args`.
4. After all folds: run post-fold `canonicalize` + `cse` to propagate constants.
5. Optional: emit diagnostic remarks or timing info in verbose mode.

## 3. Purity & Side-Effect Analysis
### Required Guarantees
- No writes except to local allocas/memrefs created within the candidate & not returned.
- No FIFO dialect ops (`fifo.*`) or CAL state ops (`cal.create_state_var`, `cal.get`, `cal.set`).
- No calls to impure functions or unknown external symbols.
- MemoryEffectOpInterface: allow `MemAlloc` + `MemRead` + local `MemWrite` if proven confined. Reject unknown effects.
- Only permitted dialect ops: `arith`, `math` (side-effect free subset), `scf`, `func.call` (to pure), `complex`. Vector and tensor ops allowed if they fully reduce to scalars or don't escape.

### Implementation Sketch
- Build call graph (node per function). DFS marking impure if any contained disallowed op or transitive callee impure.
- Local MemRef confinement: track allocas/stacks by symbol; ensure no memref escapes via return or global store.
- Track per-function purity result in a map accessible during candidate scanning.

## 4. Isolation Module Construction
- Clone selected function and all pure callees recursively into new `ModuleOp isolation`.
- Strip attributes unrelated to code generation; ensure unique symbol names (prefix with original or stable hash if collisions).
- Remove unused functions after reachability analysis.
- Insert wrapper trampoline: forwards arguments unchanged, returns the single result.

## 5. Lowering Pipeline
Minimal pipeline (inner PassManager):
```
func.func -> canonicalize
bufferize (if memref/tensor interplay required)
arith + math + complex conversions as needed (may already be legal)
convert-scf-to-cf (optional if required by LLVM lowering stack)
finalize-memref-to-llvm (memref lowering)
convert-func-to-llvm
reconcile-unrealized-casts
canonicalize, cse, licm
```
- Validate no remaining illegal ops (walk & abort if found).

## 6. ExecutionEngine Setup
- Instantiate once with `ExecutionEngine::create(isolationModule)` using JIT options:
  - Optimization level: configurable (`O0`..`O3`) via pass options.
  - Relocation model: default.
  - Register external symbols: `sin`, `cos`, `exp`, etc from `libm` via `ExecutionEngine::setupModule` symbol injection.
- Maintain map: `FunctionKey (symbol+signature) -> JITCompiledHandle {void* fnPtr, resultType, argTypes}`.

## 7. Invocation & Marshaling
- For each foldable call:
  - Construct argument vector of native C types (int32_t, float, double) from `arith.constant` operands.
  - Cast `fnPtr` to the appropriate function pointer type: `using FnTy = RetTy(*)(ArgTys...);` then call.
  - On success produce MLIR constant. If segmentation fault or exception (guarded by optional sanitizer builds) mark call non-foldable.

## 8. Caching Strategy
- Cache compiled trampoline pointer immediately after first compilation.
- Key includes callee symbol and full MLIR function type textual form.
- Second layer: result caching for identical argument tuples (e.g., repeated pow2(7)); store scalar value to avoid native call again.
- Optional LRU eviction when compiled function count > threshold (pass option).

## 9. Safety & Timeouts
- Optional wall-clock timeout per evaluation (e.g., 50ms) using std::chrono around invocation; abort if exceeded.
- Optional recursion depth limit enforced at MLIR side (not needed for compiled code but used for interpreter fallback).
- Abort on detection of unsupported opcode at runtime (should not occur after verification).

## 10. Types & Future Extensibility
Initial supported return/args: i1, i32, f32, f64.
Planned:
- Small fixed vectors lowered to LLVM structs or arrays.
- Rank-0 tensors treated as scalars.
- Multi-result functions: trampoline returns struct; post-fold produce `arith.constant` for each unpacked element.

## 11. Fallback Interpreter
- If purity check passes but lowering/JIT fails (e.g., target mismatch): attempt existing interpreter for integer-only pure recursion.
- Controlled by `--enable-interpreter-fallback` option.

## 12. Pass Options
| Option | Purpose | Default |
|--------|---------|---------|
| enable-exec-engine | Turn on JIT folding path | true |
| ee-opt-level | LLVM optimization level | O2 |
| ee-timeout-ms | Per call timeout | 0 (disabled) |
| max-rec-depth | Interpreter recursion depth | 100 |
| enable-interpreter-fallback | Use interpreter on JIT fail | true |
| ee-verbose | Emit JIT folding remarks | false |
| ee-max-functions | Max compiled functions before eviction | 256 |
| ee-max-value-cache | Max per-function arg-value cache entries | 1024 |

## 13. IR Rewrite Details
- Replacement uses `OpBuilder` at original call location.
- Attach attribute: `jit.folded_args = [<const operands textual>];` and `jit.source_symbol = <callee>`.
- If verbose: emit `emitRemark()` on function with folded value.

## 14. Testing Plan
### Positive
- pow2 recursion (depth up to 25) folded.
- factorial, fibonacci (with cut recursion limit).
- nested pure calls (pow2(factorial(3)) etc).
### Negative
- functions containing `fifo.push` / `cal.set` rejected.
- memref escaping through return causes rejection.
- side-effect call to external (simulated) rejected.
### Performance
- Benchmark multiple pow2 calls 1..100; measure time JIT vs interpreter.
- Report average fold latency and speedup factor.

## 15. Diagnostics & Logging
- `ee-verbose` prints: `jit-fold <symbol>(args...) => value [µs=<elapsed>]`.
- Option to emit debug counters (#compiled, #folded, #fallbacks).

## 16. Thread Safety
- ExecutionEngine reused; no global state beyond caches.
- Protect caches with mutex only if pass may run multi-threaded (future). For now single-thread assumption documented.

## 17. Resource Cleanup
- RAII: ExecutionEngine unique_ptr released at end of pass.
- Clear caches; ensure no dangling function pointers.

## 18. Implementation Roadmap
1. Purity analysis (tasks 38).
2. Isolation & cloning (39).
3. Lowering pipeline builder (40).
4. ExecutionEngine instantiation (41).
5. Trampoline generation & invocation (42).
6. Fold rewrite + attributes (43).
7. Caching layers (44).
8. Timeout + safety (45).
9. Fallback interpreter integration (48).
10. Post-fold cleanup & canonicalization (59).
11. Tests & benchmarks (50–52, 58).
12. Documentation (56).
13. Extended types & multi-result design (57, future).

## 19. Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| JIT compile adds latency | Cache engine + functions; batch folds before post-canon. |
| Incorrect purity marking leads to side-effects executed | Conservative analysis; blacklist dialects; require transitive purity. |
| Timeout heuristic too strict | Make configurable; default disabled. |
| ABI mismatch for types | Restrict to scalar first; assert type support upfront. |
| Memory leaks in isolation module | Use temporary owning ModuleOp; destroy after each compilation. |

## 20. Open Questions
- Should we auto-inline pure callees before lowering to reduce compilation overhead? (Potential yes as optimization pass.)
- Support for vector/tensor results: representation vs structured constant reproduction.
- Per-call vs batched evaluation ordering: currently sequential; could topologically sort call sites for better propagation.

---
This document defines the blueprint for integrating MLIRExecutionEngine into `ConstJITResolvePass`. Subsequent tasks will implement each section incrementally.
