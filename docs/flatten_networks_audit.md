# FlattenCalNetworks Pass Audit

Date: 2025-10-31

This document summarizes the current behavior and coverage of `FlattenCalNetworksPass` (lib/Transforms/FlattenNetworks/FlattenNetworks.cpp) against the RFC for symbolic network elaboration and hierarchical flattening.

## Summary

- We can reuse the existing pass and extend it. It already elaborates symbolic constructs and performs hierarchical inlining with solid diagnostics and options. Gaps mainly concern interface-typed handles, network-interface conformance, and region-based instance comprehensions.

## What it does today

- Cycle detection: builds a call graph of `cal.network` → referenced networks (via `cal.create_instance`) and rejects cycles (DFS with path reporting).
- Elaboration inside each `cal.network`:
  - `cal.instantiate` → plans for concrete `cal.create_instance` of actors.
  - `cal.instantiate_array` → N element plans; supports `basename` and parameter forwarding.
  - `cal.instance_at` → resolved only for constant `index`; if `--allow-dynamic-indices`, leaves unresolved and skips materialization.
  - `cal.connect` →
    - Port name parsing: ordinal (`in0`/`out0`), single-port alias (`in`/`out` only if no declared names), and declared names from actor’s `inPortNames`/`outPortNames`.
    - Network endpoints: supports network input/output SSA ports directly on one side; creates `fifo.create<T>(capacity)` only when both endpoints are actor instance ports.
    - Duplicate connection detection per port (seenIn/seenOut) with precise errors.
    - Capacity propagation from `cal.connect ... capacity(N)` to `fifo.create`.
  - Full-wiring requirement: enforces all ports connected for each instance plan unless `--allow-partial-connectivity`.
  - Dominance: inserts `cal.create_instance` at end of the network body to ensure operands dominate.
- Hierarchical flattening:
  - Finds `cal.create_instance` that reference `cal.network` and inlines the callee network body into the caller (argument mapping, skip nested actor/network ops).
  - Guards self-recursive instantiation and iteration limits to catch missed cycles.
- Pruning and targeting:
  - Dead network pruning (disabled via option), optional `--top=<name>` to keep only a designated network.
  - `--emit-stats` reports iterations, flattened instances, pruned networks.

## Gaps vs RFC

- Interface-typed handles:
  - `cal.connect` elaboration resolves endpoints only if they are concrete actor instance handles or network SSA ports. It does not chase through `cal.instance.cast` to interface-typed handles nor validate that the concrete entity implements the interface.
  - Port-name checking is against actor-declared names only, not interface-declared names.
- Network implements interfaces:
  - No verification that `cal.network` can `cal.implements @Iface` and that its region entry ports match interface names/types.
  - `cal.create_instance` of networks is supported for flattening, but no interface conformance is enforced.
- Region comprehensions:
  - `cal.instance_for` (and future `cal.instance_if`) are not handled in elaboration; they must be lowered or canonicalized earlier.
- Dynamic indices:
  - Optionally skipped at elaboration (`--allow-dynamic-indices`) with remarks; no late elaboration path implemented here.
- Connect sugar with array endpoints:
  - Expects canonical form (no `srcIndex`/`dstIndex`). Emits an error asking to run canonicalize first.
- Structural constants and side-effects:
  - Enforces constant `instance_at` index; other structural constants (e.g., capacities) are accepted as attributes only.

## Decision

- Reuse and extend this pass.
  - Keep elaboration and hierarchical inlining as-is.
  - Add small, focused extensions:
    1) Endpoint resolution through `cal.instance.cast` to the underlying concrete handle; verify `cal.implements` for interface conformance; allow port-name matching against interface when present.
    2) Accept interface-typed handles in `cal.connect` (both src/dst) by resolving to concrete plans; keep error messages interface-aware.
    3) Early prepass (or canonicalization) to lower `cal.instance_for`/`cal.instance_if` to `cal.instantiate(_array)` + `cal.instance_at` (constant where possible) before this pass runs.
  - Keep `--allow-dynamic-indices` behavior; add tests documenting the skipped elaboration semantics.

## Proposed next steps (minimal, incremental)

1) Verifiers:
   - Allow `cal.implements` for `cal.network`; verify port lists against interface.
2) Connect elaboration:
   - When encountering endpoints that are results of `cal.instance.cast`, chase to the defining concrete handle value and proceed; verify interface implementation (actor/network → iface) before accepting.
   - When both interface and actor declare port names, accept either interface port names or actor port names; prefer interface names in diagnostics when cast is present.
3) Precanonicalization:
   - Add a lightweight canonicalization that expands `cal.instance_for` to `cal.instantiate_array` + `cal.instance_at` with constant indices when bounds are static.
   - Ensure `cal.connect` array sugar is fully canonicalized before this pass (as already assumed).
4) Tests:
   - Positive: interface-typed connects, network implements interface, mixed name forms, capacity threading.
   - Negative: unknown interface port, cast to non-implementing iface, duplicated connects through interface view, unresolved dynamic index without flag, partial connectivity without flag.

## Notes

- The pass already ensures correct dominance for created ops and provides high-quality diagnostics for port naming and wiring errors.
- The inlining step maps region entry args correctly and avoids inlining actor or network ops themselves, preserving layering.
