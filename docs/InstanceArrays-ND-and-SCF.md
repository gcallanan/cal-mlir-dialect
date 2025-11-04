# CAL ND Instance Arrays and SCF patterns

This note documents the ND instance array types in the CAL dialect and recommended SCF-based construction patterns, along with elaboration behavior, verifiers, and pass options.

## Types

- Concrete entity arrays:
  - 1D: `!cal.instance.array<@Entity, N>`
  - ND: `!cal.instance.array<@Entity, [d0, d1, ..., dk]>`
- Interface-typed arrays:
  - 1D: `!cal.instance.array.iface<@Iface, N>`
  - ND: `!cal.instance.array.iface<@Iface, [d0, d1, ..., dk]>`

Notes:
- 1D syntax remains supported as sugar alongside the ND form.
- Use `?` to denote dynamic extents (e.g., `!cal.instance.array<@A, [?, 4]>`).

## Extent inference and canonicalization

- When creating 1D arrays via `cal.instantiate_array`, if the result type uses a dynamic extent (`[?]`) and the op has a constant `count(N)`, the canonicalizer specializes the result type to a static extent `[N]`.
  - Example (before): `%arr = cal.instantiate_array @A count(2) : !cal.instance.array<@A, [?]>`
  - After `-canonicalize`: `%arr = cal.instantiate_array @A count(2) : !cal.instance.array<@A, [2]>`

- Verifier rule (1D): If the result type already encodes a static 1D extent `[M]`, it must match the op’s `count(K)`; otherwise verification fails with a diagnostic similar to:
  - `static result type extent [M] does not match count(K)`

Notes:

- The specialization currently targets 1D arrays; ND shapes remain unchanged by this canonicalization.
- Parameter arity/type checks still apply independently of extent inference.


## Ops for array construction

- Initialize an uninitialized array value (used as an `scf.for` iter_arg):
  - `cal.instance.array.init : !cal.instance.array<@A, [M, N]>`
- Write one element (returns a new array value):
  - `cal.instance.array.set %arr[%i, %j], %h : !cal.instance.array<@A, [M, N]>, !cal.instance<@A> -> !cal.instance.array<@A, [M, N]>`

Use these in nested `scf.for` to build arrays with standard MLIR control flow.

## Element access and connections

- Extract a scalar handle from an ND array:
  - `cal.instance_at %arr[%i, %j, ...] : !cal.instance.array<@A, [..]> -> !cal.instance<@A>`
- Connect ND array endpoints directly (array + ND index tuple on each side):
  - `cal.connect %arrSrc[%i, %j] : !cal.instance.array<@A, [..]> "out" -> %arrDst[%k, %l] : !cal.instance.array<@B, [..]> "in"`

Elaboration resolves ND array indices that are statically known tuples. Dynamic indices are handled per pass option (see below).

## Verifier: verify-instance-array-fills

Enable with `--verify-instance-array-fills` in cal-opt pipelines.

- Bounds: Checks out-of-bounds when indices are compile-time constants (arith.constant). Dynamic iv indices are allowed and won’t trigger OOB diagnostics.
- Completeness (heuristic): For simple linear chains `init -> set -> set -> ...`, emits a remark if fewer than total elements are assigned with constant indices. Non-linear constructions (e.g., scf.if branches, arrays as loop iter_args) are ignored by this heuristic.

## Recipe: 2x2 array with nested scf.for

```mlir
module {
  cal.actor @A() {
    cal.execution_body {
      %false = arith.constant false
      cal.action_done %false : i1
    }
  }

  cal.network @fill_with_scf() {
    %arr0 = cal.instance.array.init : !cal.instance.array<@A, [2, 2]>

    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index

    %arr1 = scf.for %i = %c0 to %c2 step %c1 iter_args(%ai = %arr0)
        -> !cal.instance.array<@A, [2, 2]> {
      %arr2 = scf.for %j = %c0 to %c2 step %c1 iter_args(%aj = %ai)
     -> !cal.instance.array<@A, [2, 2]> {
        %h = cal.instantiate @A : <@A>
        %aj2 = cal.instance.array.set %aj[%i, %j], %h
          : !cal.instance.array<@A, [2, 2]>, !cal.instance<@A>
            -> !cal.instance.array<@A, [2, 2]>
        scf.yield %aj2 : !cal.instance.array<@A, [2, 2]>
      }
      scf.yield %arr2 : !cal.instance.array<@A, [2, 2]>
    }
  }
}
```

- With `--verify-instance-array-fills`, this will not emit out-of-bounds errors (indices are dynamic ivs) and will not emit partial-fill remarks (non-linear path via loop iter_args is ignored by the heuristic).

## Tips

- `cal.instance_at` supports ND indexing with variadic index operands matching rank.
- Late port verification (`--verify-connect-ports`) still applies after structural elaboration.

## Troubleshooting

- Partial-fill remark appears unexpectedly
  - Cause: The verifier detected a simple linear chain of `init -> set -> set -> ...` with constant indices and counted fewer assignments than the array’s total elements.
  - Fixes:
    - Complete the constant index assignments so the count matches the product of the shape extents, or
    - Build the array via `scf.for` loops with the array as an `iter_arg` (dynamic IVs) so the heuristic doesn’t apply to non-linear constructions.

- Out-of-bounds error on constant indices
  - Cause: A constant index literal was outside the array’s declared extent for that dimension.
  - Fixes: Correct the index or adjust the array’s shape.

## Elaboration options and pipeline placement

Elaboration (flattening) resolves instance arrays and connections to concrete `cal.create_instance` and `fifo.create`. Options:

- `allow-dynamic-indices`: skip materialization of connects that use dynamic ND indices and emit a remark.
- `allow-partial-connectivity`: allow partially connected arrays/instances and emit a remark where applicable.

Example:

```bash
cal-opt --flatten-cal-networks='allow-dynamic-indices allow-partial-connectivity' file.mlir
```

Recommended pipeline placement:

```bash
cal-opt -pass-pipeline='builtin.module(verify-instance-array-fills, verify-connect-ports, flatten-cal-networks, ...)' file.mlir
```

## Interface arrays: current status

- Arrays built from concrete entity handles may be cast to interface-typed handles and then written via `array.set`; elaboration follows the cast to concrete for wiring.
- `cal.instantiate_array.iface` is currently kept symbolic by elaboration (not materialized). Prefer constructing arrays from concrete handles or document this limitation in tests.

