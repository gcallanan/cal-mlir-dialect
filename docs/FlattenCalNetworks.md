# Flatten CAL Networks Pass

This document summarizes the `flatten-cal-networks` pass options and shows quick examples for common use cases.

## Overview

`flatten-cal-networks` elaborates symbolic `cal.network` structure into concrete `fifo.create` + `cal.create_instance` wiring, then iteratively flattens network instances. It also provides options to relax strictness, pick a top network, and surface progress metrics.

Key symbolic ops:

- `cal.instantiate`, `cal.instantiate_array`
- `cal.instance_at`
- `cal.connect` (supports array index sugar and interface-named ports)

## Options

- `top=<symbol>`
  - Keep only the named top-level network symbol; erase all others.
  - Example: `-pass-pipeline='builtin.module(flatten-cal-networks{top=Top})'`

- `disable-pruning`
  - Skip dead network pruning. Useful when inspecting intermediate networks.
  - Example: `-pass-pipeline='builtin.module(flatten-cal-networks{disable-pruning})'`

- `allow-partial-connectivity`
  - Do not error when some instance ports are unconnected. Emit a remark and skip materialization of that instance (and any edges touching it).
  - Example: `-pass-pipeline='builtin.module(flatten-cal-networks{allow-partial-connectivity})'`

- `allow-dynamic-indices`
  - Permit dynamic `cal.instance_at` indices or dynamic array index sugar on `cal.connect`. Such connects are skipped during elaboration (left symbolic) rather than failing.
  - Example: `-pass-pipeline='builtin.module(flatten-cal-networks{allow-dynamic-indices})'`

- `emit-stats`
  - Emit a remark summarizing iterations, flattened instance count, and pruned networks. Shows `"(pruning disabled)"` suffix when `disable-pruning` is set.
  - Example: `-pass-pipeline='builtin.module(flatten-cal-networks{emit-stats})'`

## Diagnostics

- Capacity conflicts on the same logical channel are detected and diagnosed with an error; the first capacity site is noted with a remark.
- Duplicate connects to the same port are diagnosed with context (actor symbol, instance name if present, and port index) and a remark on where the first connection occurred.
- Cycles in the network hierarchy are detected with a clear error message showing the cycle path.

## Deterministic naming

- Fully wired instances get deterministic, stable names when unnamed: `<network>.<actor>.<seq>`.
- Materialized `fifo.create` ops attach a `cal.name` attribute: `<network>.<srcInst>.out<i>-><dstInst>.in<j>`.
- `cal.create_instance` mirrors the chosen instance name in `cal.name` for convenience.

## Quick examples

Elaborate and flatten, then lower and run:

```sh
# Elaborate + flatten networks
cal-opt -pass-pipeline='builtin.module(flatten-cal-networks)' input.mlir \
  | cal-opt --lower-cal-to-llvm \
  | mlir-runner --entry-point-result=void
```

Pick a top and show stats:

```sh
cal-opt -pass-pipeline='builtin.module(flatten-cal-networks{top=Top emit-stats})' input.mlir \
  -o out.mlir
```

Allow partially connected instances:

```sh
cal-opt -pass-pipeline='builtin.module(flatten-cal-networks{allow-partial-connectivity})' input.mlir -o out.mlir
```

Allow dynamic indices and skip unresolved connects during elaboration:

```sh
cal-opt -pass-pipeline='builtin.module(flatten-cal-networks{allow-dynamic-indices})' input.mlir -o out.mlir
```
