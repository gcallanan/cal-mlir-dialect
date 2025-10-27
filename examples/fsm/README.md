# FSM example

This directory contains a minimal example demonstrating the `cal.fsm` scheduling ops.

- `minimal_fsm.mlir`: One-state FSM looping on action `"send"`, connected to a sink via FIFO.

Run it end-to-end:

```sh
cal-opt --lower-cal-to-llvm examples/fsm/minimal_fsm.mlir \
  | cal-translate --mlir-to-llvmir \
  | lli
```

Expected output: ten pairs of lines like:

```text
Src 1, pushed token: 100
Popped Token: 100
...
Src 1, pushed token: 109
Popped Token: 109
```
