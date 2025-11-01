# LowerInstanceFor pass

This pass lowers CAL instance comprehensions and simplifies array-indexed instance handles prior to full network elaboration.

## What it does

- Unrolls `cal.instance_for(lb, ub, step)` when bounds are static with `step > 0`.
- Rewrites `cal.instance_at %arr[%c]` where `%c` is a constant index to the corresponding yielded handle.
- Rewrites `cal.connect` when either side uses constant-index sugar `%arr[%c]` by substituting the direct handle and dropping the index on that side.
- Leaves dynamic indices in place (compatible with later passes when allowed by options); emits a non-fatal remark for leftovers.

## Typical pipeline

Run prior to network flattening so symbolic constructs are simplified before materialization:

```bash
cal-opt -pass-pipeline='builtin.module(lower-instance-for, flatten-cal-networks)' input.mlir
```

## Constraints and notes

- The `cal.instantiate` op must be in `cal.network` scope. Inside the `cal.instance_for` body, yield pre-instantiated handles from the network scope using `cal.instance_yield`.
- For zero-trip ranges (e.g., `lb == ub`), the pass yields an empty tuple/array as appropriate.
- Dynamic indices are not folded by this pass. Use `flatten-cal-networks{allow-dynamic-indices}` if you want elaboration to tolerate them.
- The pass avoids failing; unresolved rewrites result in diagnostics but not errors.

## Mini example

Input (symbolic):

```mlir
cal.network @N() {
  %c0 = arith.constant 0 : index
  %c2 = arith.constant 2 : index
  %c1 = arith.constant 1 : index

  %h = cal.instantiate @A : !cal.instance<@A>
  %arr = cal.instance_for(%c0, %c2, %c1) {
    cal.instance_yield %h : !cal.instance<@A>
  } : !cal.instance.array<@A, 2>

  %a1 = cal.instance_at %arr[%c1] : !cal.instance.array<@A, 2>, index -> !cal.instance<@A>
  cal.connect %arr[%c0] : !cal.instance.array<@A, 2> "out" -> %a1 : !cal.instance<@A> "in"
}
```

After `lower-instance-for`, `%a1` is a direct handle and the connect no longer uses index sugar on the left. After `flatten-cal-networks`, FIFOs and `cal.create_instance` are materialized.
